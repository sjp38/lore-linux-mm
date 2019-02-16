Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,
	MAILING_LIST_MULTI,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 192CCC43381
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 11:14:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B8711222DD
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 11:14:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="YwY46r4Z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B8711222DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5361D8E0003; Sat, 16 Feb 2019 06:14:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4E6898E0001; Sat, 16 Feb 2019 06:14:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D74E8E0003; Sat, 16 Feb 2019 06:14:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 116348E0001
	for <linux-mm@kvack.org>; Sat, 16 Feb 2019 06:14:32 -0500 (EST)
Received: by mail-vk1-f200.google.com with SMTP id e13so5482806vka.5
        for <linux-mm@kvack.org>; Sat, 16 Feb 2019 03:14:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qUb8JZvTZhfgAaAiSnwTAaBVMsCxl60RgFzP1PX53Cc=;
        b=FQ01RbbukIllOG4YBIyTSD4GMgipAuZS4F6jrfGPwiP781Y8NHbebaJMB1GOoBIzBb
         3bPwBV6phwKgxDFH9zxCUh67i4DDTGnokPnk9njbNgS3AwsZnv74wkPOX2/ml0dv5A9E
         s8VIWT/QR0OgK8fQYu4nGWP/5x8XLDV07j9nGwQvMcE4SKRMi7r1Zgt9+YNBR0DoqSAf
         la3Yr2YHI4f7VcsfU/MetDF8xT16lt5JSfTyA4eyVuLX4l54bZMmNzjZv0jgT9/7oyn4
         ZIV/wl0rLJVZJDnHAvnE5/+hsdYGfTpkgw+lbILk0efZGrfmlWE/tVvf29w8fTpX8z3F
         PFow==
X-Gm-Message-State: AHQUAubTd6pkDNMcJ8FXx9rEr87L92gCknyXyRqHYbLbeeGlt3bej4fk
	yIkjJ3UIUCT5iTJWSOLZeMUBkSbm/5Vu/eSE5n4SW74viKsko3Xsg9ZYJju4mqOKBCsgyjN3sbb
	VnktOi2aJBPCca8zgp5n+yhPe1mxYvDO93Wi9EjPfPvqI7FNcS96lKz2FLYTlCqKR3YuLLR5Zgx
	xx3zHx42gLSA374CWF3rTmhMKYoc/IgtYOITZLPGsoZQpyg5nhSZcxDnYzIDyN4FAVze8b0qVXD
	AISGeFNwxEkDLJOfh6wtCelkTipEYN8HRq5nj9c6uG7ZL52SZRBCyCVKc6ENUxOhcRlVKw/mwK1
	m2jrYqpIpfWbXrkm6Z+d0BzOVHA5YtIq5NpX1mGJzowFOSHBw4Drwk/2qn8Th6tk1oxOI1shLg+
	F
X-Received: by 2002:a67:ea50:: with SMTP id r16mr7124474vso.61.1550315671701;
        Sat, 16 Feb 2019 03:14:31 -0800 (PST)
X-Received: by 2002:a67:ea50:: with SMTP id r16mr7124454vso.61.1550315671011;
        Sat, 16 Feb 2019 03:14:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550315671; cv=none;
        d=google.com; s=arc-20160816;
        b=F0biV0zGy7NVMWFDYPOEzgYOa7jm/2ARPbLW0tQIFEcwU/HnTuV9JhWnGDMHH9u+d4
         f9GpvmyiXWPov0swwimMJRz7fPJSexvC9keAIE1HZUTcIxFd+b8JVufWuReegVqy1fZj
         JdDQyBgt3Q4cvpsnchy7GptxOxhTbFWRw7MMVC0Qi0+E57VvOn3qZCatmYtrb2grRw1a
         IP2CNWefFFq6aF0N/BMu0bCUjaq74x9GLJTw07uocpa5xvbFmtEL1+oE1T92zA/ecRXR
         o2A7XEyY2WHhJK/dYUIG2Ml/Cg7tHXuZH4D2NT3Cq9BBTm7h0hV6ON5o1enaWBsFLxb5
         bmYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qUb8JZvTZhfgAaAiSnwTAaBVMsCxl60RgFzP1PX53Cc=;
        b=i2NqA+R+6DxbhduBZrbxtEJuzj4IEaHz0O/gdPEUxH1qC5boZ7Xg4dJKufOgw1r/CI
         NtXXfF8xuJehvte7n+UKtM41epTZDil+kMcVRfkexB0suT3O7AZ88fhpDLsUcc2ZeSOs
         q6jpFPqKM79Su+vVh45NlDkBWV4dHL9sRVPnvhCSark5JHrjhGBW+jDYw+LgtHB7z9RY
         wEApyUHq1EncPW39VIUMxuv6B/dpTy6OldPDr51wRNjZExzkZjav3i189D9oirbRr0Bj
         59ploeN7gFfZDhRUBpj80VsWMmoNHiHX/8gQIfFDBTz6tTD1P8yhV6yWqX7op2sllF4+
         5JxA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YwY46r4Z;
       spf=pass (google.com: domain of pjt@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pjt@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 131sor4262176vke.10.2019.02.16.03.14.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 16 Feb 2019 03:14:30 -0800 (PST)
Received-SPF: pass (google.com: domain of pjt@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YwY46r4Z;
       spf=pass (google.com: domain of pjt@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pjt@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qUb8JZvTZhfgAaAiSnwTAaBVMsCxl60RgFzP1PX53Cc=;
        b=YwY46r4Ze722wP39ugONEb1XbAqSrgyPWNVgsJbi0LgR6LOa2+uxRAJp4yNebxuA1b
         HLqbWMO1z4Kn8YN/Pg36koL3gb18BoTrvKMskwxaIp7P1cdmVS9HOddG4rWf1AUf7UnR
         AA7jtpnBQ/b6wb6dOLV7UstdT5B3OWIDnwaiQojR50yVz25//nGnI+GwNs5u+ZWk24AR
         Oxl5d5whjuQ+dyTNJi8UbPC6fx4vcOZFAjbzaQ4YCpp5SiHqAg46fovOGXe/7JCL75RE
         fP+MUWMvRKQePxmec7Z7fUajf4ZZEhWUmsm5X24nP5Gru4QXfW6xjmmYOZtX564ReVuw
         G+7w==
X-Google-Smtp-Source: AHgI3Iam9j5HPUWH08pqZ9RAfl9lyVcjVENo91jJID0xXJNXkC3AeGJ3XhbnWxIn0Ht6wL4LLSKihGT/MDmXnvOAwEg=
X-Received: by 2002:a1f:bd15:: with SMTP id n21mr7049347vkf.35.1550315670259;
 Sat, 16 Feb 2019 03:14:30 -0800 (PST)
MIME-Version: 1.0
References: <20190207072421.GA9120@rapoport-lnx> <CA+VK+GOpjXQ2-CLZt6zrW6m-=WpWpvcrXGSJ-723tRDMeAeHmg@mail.gmail.com>
In-Reply-To: <CA+VK+GOpjXQ2-CLZt6zrW6m-=WpWpvcrXGSJ-723tRDMeAeHmg@mail.gmail.com>
From: Paul Turner <pjt@google.com>
Date: Sat, 16 Feb 2019 03:13:52 -0800
Message-ID: <CAPM31RKpR0EZoeXZMXciTxvjBEeu3Jf3ks4Dn9gERxXghoB67w@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Address space isolation inside the kernel
To: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, 
	James Bottomley <James.Bottomley@hansenpartnership.com>, Mike Rapoport <rppt@linux.ibm.com>
Cc: Jonathan Adams <jwadams@google.com>
Content-Type: multipart/alternative; boundary="000000000000d17ffc058200fe22"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000d17ffc058200fe22
Content-Type: text/plain; charset="UTF-8"

I wanted to second the proposal for address space isolation.

We have some new techniques to introduce her also, built around some new
ideas using page-faults that we believe are interesting.

To wit, page faults uniquely allow us to fork speculative and
non-speculative execution as we can control the retired path within the
fault itself (which as it turns out, will obviously never be executed
speculatively).

This lets us provide isolation against variant1 gadgets, as well as
guarantee what data may or may not be cache present for the purposes of
L1TF and Meltdown mitigation.

I'm not sure whether or not I'll be able to attend (I have a newborn and
there's a lot of other scheduling I'm trying to work out).  But Jonathan
Adams (cc'd) has been working on this and can speak to it.  We also have
some write-ups to publish independently of this.

Thanks,

- Paul

(Joint proposal with James Bottomley)
>
> Address space isolation has been used to protect the kernel from the
> userspace and userspace programs from each other since the invention of
> the virtual memory.
>
> Assuming that kernel bugs and therefore vulnerabilities are inevitable
> it might be worth isolating parts of the kernel to minimize damage
> that these vulnerabilities can cause.
>
> There is already ongoing work in a similar direction, like XPFO [1] and
> temporary mappings proposed for the kernel text poking [2].
>
> We have several vague ideas how we can take this even further and make
> different parts of kernel run in different address spaces:
> * Remove most of the kernel mappings from the syscall entry and add a
>   trampoline when the syscall processing needs to call the "core
>   kernel".
> * Make the parts of the kernel that execute in a namespace use their
>   own mappings for the namespace private data
> * Extend EXPORT_SYMBOL to include a trampoline so that the code
>   running in modules won't map the entire kernel
> * Execute BFP programs in a dedicated address space
>
> These are very general possible directions. We are exploring some of
> them now to understand if the security value is worth the complexity
> and the performance impact.
>
> We believe it would be helpful to discuss the general idea of address
> space isolation inside the kernel, both from the technical aspect of
> how it can be achieved simply and efficiently and from the isolation
> aspect of what actual security guarantees it usefully provides.
>
> [1]
> https://lore.kernel.org/lkml/cover.1547153058.git.khalid.aziz@oracle.com/
> [2]
> https://lore.kernel.org/lkml/20190129003422.9328-4-rick.p.edgecombe@intel.com/
>
> --
> Sincerely yours,
> Mike.
>

--000000000000d17ffc058200fe22
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_quote"><div>I wanted to second the pro=
posal for address space isolation.</div><div><br></div><div>We have some ne=
w techniques to introduce her also, built around some new ideas using page-=
faults that we believe are interesting.</div><div><br></div><div>To wit, pa=
ge faults uniquely allow us to fork speculative and non-speculative executi=
on as we can control the retired path within the fault itself (which as it =
turns out, will obviously never be executed speculatively).</div><div><br><=
/div><div>This lets us provide isolation against variant1 gadgets, as well =
as guarantee what data may or may not be cache present for the purposes of =
L1TF and Meltdown mitigation.=C2=A0=C2=A0</div><div><br></div><div>I&#39;m =
not sure whether or not I&#39;ll be able to attend (I have a newborn and th=
ere&#39;s a lot of other scheduling I&#39;m trying to work out).=C2=A0 But =
Jonathan Adams (cc&#39;d) has been working on this and can speak to it.=C2=
=A0 We also have some write-ups to publish independently of this.</div><div=
><br></div><div>Thanks,</div><div><br></div><div>- Paul</div><div><br></div=
><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border=
-left:1px solid rgb(204,204,204);padding-left:1ex">(Joint proposal with Jam=
es Bottomley)<br>
<br>
Address space isolation has been used to protect the kernel from the<br>
userspace and userspace programs from each other since the invention of<br>
the virtual memory.<br>
<br>
Assuming that kernel bugs and therefore vulnerabilities are inevitable<br>
it might be worth isolating parts of the kernel to minimize damage<br>
that these vulnerabilities can cause.<br>
<br>
There is already ongoing work in a similar direction, like XPFO [1] and<br>
temporary mappings proposed for the kernel text poking [2].<br>
<br>
We have several vague ideas how we can take this even further and make<br>
different parts of kernel run in different address spaces:<br>
* Remove most of the kernel mappings from the syscall entry and add a<br>
=C2=A0 trampoline when the syscall processing needs to call the &quot;core<=
br>
=C2=A0 kernel&quot;.<br>
* Make the parts of the kernel that execute in a namespace use their<br>
=C2=A0 own mappings for the namespace private data<br>
* Extend EXPORT_SYMBOL to include a trampoline so that the code<br>
=C2=A0 running in modules won&#39;t map the entire kernel<br>
* Execute BFP programs in a dedicated address space<br>
<br>
These are very general possible directions. We are exploring some of<br>
them now to understand if the security value is worth the complexity<br>
and the performance impact.<br>
<br>
We believe it would be helpful to discuss the general idea of address<br>
space isolation inside the kernel, both from the technical aspect of<br>
how it can be achieved simply and efficiently and from the isolation<br>
aspect of what actual security guarantees it usefully provides.<br>
<br>
[1] <a href=3D"https://lore.kernel.org/lkml/cover.1547153058.git.khalid.azi=
z@oracle.com/" rel=3D"noreferrer" target=3D"_blank">https://lore.kernel.org=
/lkml/cover.1547153058.git.khalid.aziz@oracle.com/</a><br>
[2] <a href=3D"https://lore.kernel.org/lkml/20190129003422.9328-4-rick.p.ed=
gecombe@intel.com/" rel=3D"noreferrer" target=3D"_blank">https://lore.kerne=
l.org/lkml/20190129003422.9328-4-rick.p.edgecombe@intel.com/</a><br>
<br>
--<br>
Sincerely yours,<br>
Mike.<br>
</blockquote></div></div>

--000000000000d17ffc058200fe22--

