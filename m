Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C90CC282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 07:09:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4AEA21773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 07:09:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pwORRFPa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4AEA21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 31FC58E0013; Tue, 12 Feb 2019 02:09:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2CF828E000D; Tue, 12 Feb 2019 02:09:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 197EE8E0013; Tue, 12 Feb 2019 02:09:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id B241D8E000D
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 02:09:27 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id w4so620765wrt.21
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 23:09:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=l/Y2H+sPvFaqE/igdudgnurdiLS0gT5wulBquThog6U=;
        b=T/qoJBb2bDpH8x0UOBGvkyv991PNTXPPMSuEOnl9Q01UrphU7Zf0wlPZClSfrsuOFj
         mpmcaLYLIN4utVjkvSs2L9zQo5Gw0cOuPN+8gAAEIW9iXBwJ6b5UIYXUqpyfSI+csdSZ
         oJeIv1rk5CBIG/61o+6HbunG70LAAKisKfhWRBAK5i2VtGPSP945YIBH3bIHwU4E3+tQ
         ITI9WAVDoJwYJQlh2TgPtdM6He5CAbpgS9P3ob0DWMmrGnF9xlSoeVuMT42O0rrM1YS5
         AR01Et9mIQucoPnE0SMGgb9Mbt6jC92U+dUOA4sptjzD2+e4zud7NdhNB2koAqFrHDcN
         Mj+w==
X-Gm-Message-State: AHQUAuamUXBXRL3xUq/ErpbZgMdUl8+NikAT5/XuSy0AeWVMhZ6QkKJi
	6HBj8OHVjehVVKRD3nVaj0ygn9r3H03pl/UykU4sNNTtkARDa7xw8uBDTwCykOGtk+FQxP8mRhj
	OdnRBPWIjzdevL5WKS3Hl6UiqYgIHn/jP7u5MLM1SgG4aG6qle8ZDTgtgsbgmKnXhmrsOnQhXnv
	8HbBIbdChhP0yApugGpV12DcOBJvckojLuwnSDa8ud+0tR/EurPM/Od4Qy3a0Xs5bDEcadN1iey
	jdAs407aD+oTSDP762ghDThfXO5mo9QAOL3Pt+j9TXk0Qe7V7gtdnsdrns98rmLWVWCAnAWVWOm
	b8WcqORgEOs4cK8b9fCVAloJU49uKC2xYQJHcIn+gdH0+gJLjvOxVgsgWNXSYiFLJD6u9JmTvE4
	O
X-Received: by 2002:a5d:4145:: with SMTP id c5mr1608276wrq.256.1549955367129;
        Mon, 11 Feb 2019 23:09:27 -0800 (PST)
X-Received: by 2002:a5d:4145:: with SMTP id c5mr1608216wrq.256.1549955366216;
        Mon, 11 Feb 2019 23:09:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549955366; cv=none;
        d=google.com; s=arc-20160816;
        b=dIgRYhg8irh9qVWsMj5gTNeT5HrdH6qxwtdzYXjtTNMRAOJMER0UAFQvhI6pc1UZYz
         pZGsptZcqDqTol/yjHkUGF8pdudrvgn7SNh/it+3AgKPHewZtEUgMvb3ucVzoCA34Beg
         3UAB1pxdtQAodgEXFRqdWFMXC+YRRb7jkZ2GDCgk1lVNH8JcA6X1TVjtD5rCTB2NBsE0
         XN1Mf3tP4eWjuXOtNVXuiMXgLvS8Qx3q5g5EmDb7cL5+PmZWjyv8KdONnanctDncTj8I
         dRfSo1iB4+Sgp6FvcLwIV1u9p0xG4G6jAoa0yUHthN3km9DL89r2IcTeiC2FyHhqHgIm
         EWFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=l/Y2H+sPvFaqE/igdudgnurdiLS0gT5wulBquThog6U=;
        b=IT8ybqGj5CRWgVyRGhXU1XSPVCHKa4rR7+GtN+3dSfu/A7un8TNnkgu+AKGS8MLMOE
         RKzoM3qWvn3lx3Kcza63Lmk2akpVPHgQTcGcEY0g4QMlzuv6MwPSy2WoMUQLzIz7FRBM
         XilPcB0KTSY43Ls5NBo7zVHQeQ+NqT0Aiyza3dmW3K239qRitqZmRZQYLRJf05CefTsS
         UBC3lu700mHvbvwkH19FIEBgxGw3plolK2OT7+zJcyNSvt0l/bxZemuYKxkLqnWnVaP/
         IlOLLElflRkJST2VrbWhiFgfTUB+CG/MiuOd9JLgFRzpotqW+sUAVB9bQum/QS8uSj5c
         IVTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pwORRFPa;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t13sor1052479wmt.4.2019.02.11.23.09.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 23:09:26 -0800 (PST)
Received-SPF: pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pwORRFPa;
       spf=pass (google.com: domain of igor.stoppa@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=igor.stoppa@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=l/Y2H+sPvFaqE/igdudgnurdiLS0gT5wulBquThog6U=;
        b=pwORRFPa1ESmuwNrsUe4YUF2SQMcZdGoAv+3pXsyYo0Abjc3K4Fp6yWRi+FgSfjWYl
         YOlAOSasNwBaF/AQencIviRfPv8UQtQDoQsVw9tsN7vQdA0m8gQwNXA+3jKaygrzo/eu
         XeyXFs+glZUDzJklvqvQapfFpkEvAZexqqkMZ2sdcNQ12CE8DvA/iSjCqlIPb2D+ztTR
         EhcLg+d2jse8gV2Y2aFgi+YYGzGwrGDurLyxzVck4E+nvNk3z3DKqjXoTE/QEy5tewe/
         KSCxImDCrFn1YoGpYevYNsA/n+j244PkKj8LGc/OLuiWG8+IxHn62SZLZnZRy0dJEZvl
         VDQA==
X-Google-Smtp-Source: AHgI3IZYUHYW3esJ4vMMAP1gkcxO2jgtBZcY/GRbFKYx76jqMuZpS+nVPuiAATCoZ09Azb9xUdkVDQ==
X-Received: by 2002:a1c:e1c4:: with SMTP id y187mr1687569wmg.50.1549955365667;
        Mon, 11 Feb 2019 23:09:25 -0800 (PST)
Received: from [172.20.11.181] (bba133882.alshamil.net.ae. [217.165.112.24])
        by smtp.gmail.com with ESMTPSA id d9sm15932320wrn.72.2019.02.11.23.09.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 23:09:24 -0800 (PST)
Subject: Re: [RFC PATCH v4 00/12] hardening: statically allocated protected
 memory
To: Kees Cook <keescook@chromium.org>
Cc: Igor Stoppa <igor.stoppa@huawei.com>,
 Ahmed Soliman <ahmedsoliman@mena.vt.edu>,
 linux-integrity <linux-integrity@vger.kernel.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux-MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <cover.1549927666.git.igor.stoppa@huawei.com>
 <CAGXu5j+n3ky2dOe4F+VyneQsM4VJbGPUw+DO55NkxxPhKzKHag@mail.gmail.com>
 <25bf3c63-c54c-f7ea-bec1-996a2c05d997@gmail.com>
 <CAGXu5jLqmYRUVLb7-jPsN4onO5UNH+D6qOF=9TOiVjJa-=DnZQ@mail.gmail.com>
 <CAH2bzCRZ5xYOT0R8piqZx4mSGj1_8fNG=Ce4UU8i6F7mYD9m9Q@mail.gmail.com>
 <CAGXu5jLRJZuWjnwEuK=7AMeCrj-eioVGksPL9dE9pbzHM=+Rmg@mail.gmail.com>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <29cd9541-9af2-fc1c-c264-f4cb9c29349a@gmail.com>
Date: Tue, 12 Feb 2019 09:09:22 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAGXu5jLRJZuWjnwEuK=7AMeCrj-eioVGksPL9dE9pbzHM=+Rmg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 12/02/2019 03:26, Kees Cook wrote:
> On Mon, Feb 11, 2019 at 5:08 PM igor.stoppa@gmail.com
> <igor.stoppa@gmail.com> wrote:
>>
>>
>>
>> On Tue, 12 Feb 2019, 4.47 Kees Cook <keescook@chromium.org wrote:
>>>
>>> On Mon, Feb 11, 2019 at 4:37 PM Igor Stoppa <igor.stoppa@gmail.com> wrote:
>>>>
>>>>
>>>>
>>>> On 12/02/2019 02:09, Kees Cook wrote:
>>>>> On Mon, Feb 11, 2019 at 3:28 PM Igor Stoppa <igor.stoppa@gmail.com> wrote:
>>>>> It looked like only the memset() needed architecture support. Is there
>>>>> a reason for not being able to implement memset() in terms of an
>>>>> inefficient put_user() loop instead? That would eliminate the need for
>>>>> per-arch support, yes?
>>>>
>>>> So far, yes, however from previous discussion about power arch, I
>>>> understood this implementation would not be so easy to adapt.
>>>> Lacking other examples where the extra mapping could be used, I did not
>>>> want to add code without a use case.
>>>>
>>>> Probably both arm and x86 32 bit could do, but I would like to first get
>>>> to the bitter end with memory protection (the other 2 thirds).
>>>>
>>>> Mostly, I hated having just one arch and I also really wanted to have arm64.
>>>
>>> Right, I meant, if you implemented the _memset() case with put_user()
>>> in this version, you could drop the arch-specific _memset() and shrink
>>> the patch series. Then you could also enable this across all the
>>> architectures in one patch. (Would you even need the Kconfig patches,
>>> i.e. won't this "Just Work" on everything with an MMU?)
>>
>>
>> I had similar thoughts, but this answer [1] deflated my hopes (if I understood it correctly).
>> It seems that each arch needs to be massaged in separately.
> 
> True, but I think x86_64, x86, arm64, and arm will all be "normal".
> power may be that way too, but they always surprise me. :)
> 
> Anyway, series looks good, but since nothing uses _memset(), it might
> make sense to leave it out and put all the arch-enabling into a single
> patch to cover the 4 archs above, in an effort to make the series even
> smaller.

Actually, I do use it, albeit indirectly.
That's the whole point of having the IMA patch as example.

This is the fragment:
----------------
@@ -460,12 +460,13 @@ void ima_update_policy_flag(void)

  	list_for_each_entry(entry, ima_rules, list) {
  		if (entry->action & IMA_DO_MASK)
-			ima_policy_flag |= entry->action;
+			wr_assign(ima_policy_flag,
+				  ima_policy_flag | entry->action);
  	}

  	ima_appraise |= (build_ima_appraise | temp_ima_appraise);
  	if (!ima_appraise)
-		ima_policy_flag &= ~IMA_APPRAISE;
+		wr_assign(ima_policy_flag, ima_policy_flag & ~IMA_APPRAISE);
  }
----------------

wr_assign() does just that.

However, reading again your previous mails, I realize that I might have 
misinterpreted what you were suggesting.

If the advice is to have also a default memset_user() which relies on 
put_user(), but do not activate the feature by default for every 
architecture, I definitely agree that it would be good to have it.
I just didn't think about it before.

What I cannot do is to turn it on for all the architectures prior to 
test it and atm I do not have means to do it.

But I now realize that most likely you were just suggesting to have 
full, albeit inefficient default support and then let various archs 
review/enhance it. I can certainly do this.

Regarding testing I have a question: how much can/should I lean on qemu?
In most cases the MMU might not need to be fully emulated, so I wonder 
how well qemu-based testing can ensure that real life scenarios will work.

--
igor

