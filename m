Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	HTML_MESSAGE,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FF23C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 21:42:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CAE22085A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 21:42:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CAE22085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A69336B0269; Mon, 13 May 2019 17:42:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A193A6B026A; Mon, 13 May 2019 17:42:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 908016B026B; Mon, 13 May 2019 17:42:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 565C36B0269
	for <linux-mm@kvack.org>; Mon, 13 May 2019 17:42:55 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id e20so10417272pfn.8
        for <linux-mm@kvack.org>; Mon, 13 May 2019 14:42:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:mime-version;
        bh=4WsEukJt4QL54JGtqy+DlOk3x8JqGQbOVxe7TpPlfcg=;
        b=Tmb3izpoMuENvJzh5/7QWQzrxJV6EgXHwSA7k1P+dOJOlYPP88+IFn5JgKxBRYaYe6
         gwByGHpcyZgKFo0ErDhnNtLxsqU+OX/f2wiWTGr+5przsGVrlPDLH/k6s1W9WpyMkpE6
         Mz7B8cm98AidyOdRCIPASaIgc94UxudXbhp8gRUz9y6vsvaXYD50lq06R2Kx17JVcmmG
         0HPPGePd+J8pnhAv93YnIa8eW/tZ+XKKOKc2YoD1bMJtpRSdu5H1436fTC65Q6+/U2sw
         1TLRT30B5OGEWVYE30aqfFDrocIdZJM8szZ2lBklF2VHK8Q91Ex/wvLQEFXoW0NtUIZZ
         Wkkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jun.nakajima@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=jun.nakajima@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWxsktIzrahCCvthWX8620GjBlVjYXJ0z380iBRu7/+e3fXc41j
	/CNCrXIaLoS7EvwFOGtB2RqcTD7zphZlTXqu6wDJzBJ4Fr45AvAlUl4+4eT8zU8xLSc3wWeHwzT
	74GSJj13wtn5+ALESKULClNO8wDC2aF5tzNs6PKcJl/bW+H5c/SkDewebNjeaEU/sqQ==
X-Received: by 2002:a63:c50c:: with SMTP id f12mr33954811pgd.71.1557783774853;
        Mon, 13 May 2019 14:42:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwoTbDe+wGvvGWhqOxPc3Jno4ZgXobm52xZxYUjjTrrWJW0lyw2W32tkbyymOuyB9L0h9MU
X-Received: by 2002:a63:c50c:: with SMTP id f12mr33954775pgd.71.1557783774084;
        Mon, 13 May 2019 14:42:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557783774; cv=none;
        d=google.com; s=arc-20160816;
        b=ASxA3oK6NZuLKkUr4uv024nRg+ScqgMop+r0BR0JU0gQXDFjh9rbVtUouo0Vit3l7i
         4GtfFvwD7C5c7Jh5NNLIfej3/nfUrPdvxlOZHZgyoYpGM6AFO35OSfXHC6Po4ybxlIYO
         Sxd4bn+7xXSoA9eXsunLO307EolVOLmOaZXsPMJHlCkv78GOKSsexT4uWv59qjgyGj8R
         kte/oJg/cuJ1AxASOxxyLY0hw1LpmaI8vREY+vvXPJc3jA87Ik2HwlGNDGM7ytVZC27/
         CnjkCcUfC6D2YmsRjpvzm1rkMiIP2CyLUf+gObKlKmuUf6nytzZpcrztLNdD1SbeZmdR
         0nHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-language:accept-language:in-reply-to
         :references:message-id:date:thread-index:thread-topic:subject:cc:to
         :from;
        bh=4WsEukJt4QL54JGtqy+DlOk3x8JqGQbOVxe7TpPlfcg=;
        b=r5m0eXYm8rVwWvQ0u3j/qMRmleS7gJt45JorYfo8rPRqdT/pQ8GNNxiL/40XsVf+Te
         hGt+qJMz2fXiIoc6AAMph60+azkyRRMkugAGh+3CsIuKTzNr2JLupuGVMKrj8KOdHkiN
         aXLJ1dZZGGer6qZAyfb1Xd3V2umhMEwqwnZSCEJ8b9IbGJDmZne9o+PMdCCHn2sGcKvy
         OVe6Yaq9sq2hwgXFEp7AcRKTjTx4FDzRjEMvmuhIIZl318hJruqGXGKqauv7HLqJ2SS7
         WeESVKSSn7kLLc9M1DxRIUbQMPNKJeqBDgJ9Xhz1B+mhRh/f7F3gJplwWVR143+4lBDc
         kJOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jun.nakajima@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=jun.nakajima@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 21si7889664pfc.98.2019.05.13.14.42.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 14:42:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jun.nakajima@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jun.nakajima@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=jun.nakajima@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 May 2019 14:42:53 -0700
X-ExtLoop1: 1
Received: from fmsmsx103.amr.corp.intel.com ([10.18.124.201])
  by fmsmga005.fm.intel.com with ESMTP; 13 May 2019 14:42:53 -0700
Received: from fmsmsx101.amr.corp.intel.com ([169.254.1.164]) by
 FMSMSX103.amr.corp.intel.com ([169.254.2.58]) with mapi id 14.03.0415.000;
 Mon, 13 May 2019 14:42:53 -0700
From: "Nakajima, Jun" <jun.nakajima@intel.com>
To: Liran Alon <liran.alon@oracle.com>
CC: Alexandre Chartre <alexandre.chartre@oracle.com>, "pbonzini@redhat.com"
	<pbonzini@redhat.com>, "rkrcmar@redhat.com" <rkrcmar@redhat.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com"
	<mingo@redhat.com>, "bp@alien8.de" <bp@alien8.de>, "hpa@zytor.com"
	<hpa@zytor.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>,
	"luto@kernel.org" <luto@kernel.org>, "peterz@infradead.org"
	<peterz@infradead.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"jan.setjeeilers@oracle.com" <jan.setjeeilers@oracle.com>,
	"jwadams@google.com" <jwadams@google.com>
Subject: Re: [RFC KVM 00/27] KVM Address Space Isolation
Thread-Topic: [RFC KVM 00/27] KVM Address Space Isolation
Thread-Index: AQHVCZo0+3UN0P2FyECwVvtVyp68J6ZpcaEAgACSxACAAAdfgA==
Date: Mon, 13 May 2019 21:42:52 +0000
Message-ID: <D07C8F51-F2DF-4C8B-AB3B-0DFABD5F4C33@intel.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <11F6D766-EC47-4283-8797-68A1405511B0@intel.com>
 <46FF68B2-3284-4705-A904-328992449D43@oracle.com>
In-Reply-To: <46FF68B2-3284-4705-A904-328992449D43@oracle.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.254.35.195]
Content-Type: multipart/alternative;
	boundary="_000_D07C8F51F2DF4C8BAB3B0DFABD5F4C33intelcom_"
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--_000_D07C8F51F2DF4C8BAB3B0DFABD5F4C33intelcom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable



On May 13, 2019, at 2:16 PM, Liran Alon <liran.alon@oracle.com<mailto:liran=
.alon@oracle.com>> wrote:

On 13 May 2019, at 22:31, Nakajima, Jun <jun.nakajima@intel.com<mailto:jun.=
nakajima@intel.com>> wrote:

On 5/13/19, 7:43 AM, "kvm-owner@vger.kernel.org<mailto:kvm-owner@vger.kerne=
l.org> on behalf of Alexandre Chartre" wrote:

  Proposal
  =3D=3D=3D=3D=3D=3D=3D=3D

  To handle both these points, this series introduce the mechanism of KVM
  address space isolation. Note that this mechanism completes (a)+(b) and
  don't contradict. In case this mechanism is also applied, (a)+(b) should
  still be applied to the full virtual address space as a defence-in-depth)=
.

  The idea is that most of KVM #VMExit handlers code will run in a special
  KVM isolated address space which maps only KVM required code and per-VM
  information. Only once KVM needs to architectually access other (sensitiv=
e)
  data, it will switch from KVM isolated address space to full standard
  host address space. At this point, KVM will also need to kick all sibling
  hyperthreads to get out of guest (note that kicking all sibling hyperthre=
ads
  is not implemented in this serie).

  Basically, we will have the following flow:

    - qemu issues KVM_RUN ioctl
    - KVM handles the ioctl and calls vcpu_run():
      . KVM switches from the kernel address to the KVM address space
      . KVM transfers control to VM (VMLAUNCH/VMRESUME)
      . VM returns to KVM
      . KVM handles VM-Exit:
        . if handling need full kernel then switch to kernel address space
        . else continues with KVM address space
      . KVM loops in vcpu_run() or return
    - KVM_RUN ioctl returns

  So, the KVM_RUN core function will mainly be executed using the KVM addre=
ss
  space. The handling of a VM-Exit can require access to the kernel space
  and, in that case, we will switch back to the kernel address space.

Once all sibling hyperthreads are in the host (either using the full kernel=
 address space or user address space), what happens to the other sibling hy=
perthreads if one of them tries to do VM entry? That VCPU will switch to th=
e KVM address space prior to VM entry, but others continue to run? Do you t=
hink (a) + (b) would be sufficient for that case?

The description here is missing and important part: When a hyperthread need=
s to switch from KVM isolated address space to kernel full address space, i=
t should first kick all sibling hyperthreads outside of guest and only then=
 safety switch to full kernel address space. Only once all sibling hyperthr=
eads are running with KVM isolated address space, it is safe to enter guest=
.


Okay, it makes sense. So, it will require some synchronization among the si=
blings there.

The main point of this address space is to avoid kicking all sibling hypert=
hreads on *every* VMExit from guest but instead only kick them when switchi=
ng address space. The assumption is that the vast majority of exits can be =
handled in KVM isolated address space and therefore do not require to kick =
the sibling hyperthreads outside of guest.


---
Jun
Intel Open Source Technology Center

--_000_D07C8F51F2DF4C8BAB3B0DFABD5F4C33intelcom_
Content-Type: text/html; charset="us-ascii"
Content-ID: <E57D58E7EEF9C948ADD7E67A7B44391F@intel.com>
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dus-ascii"=
>
</head>
<body style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; line-break:=
 after-white-space;" class=3D"">
<div class=3D"">
<div style=3D"word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line=
-break: after-white-space;" class=3D"">
<div style=3D"color: rgb(0, 0, 0); font-family: Arial; font-size: 12px; fon=
t-style: normal; font-variant-caps: normal; font-weight: normal; letter-spa=
cing: normal; orphans: auto; text-align: start; text-indent: 0px; text-tran=
sform: none; white-space: normal; widows: auto; word-spacing: 0px; -webkit-=
text-stroke-width: 0px;">
<br class=3D"">
</div>
</div>
</div>
<div><br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">On May 13, 2019, at 2:16 PM, Liran Alon &lt;<a href=3D"mail=
to:liran.alon@oracle.com" class=3D"">liran.alon@oracle.com</a>&gt; wrote:</=
div>
<div class=3D"">
<div class=3D""><br class=3D"">
<blockquote type=3D"cite" class=3D"">On 13 May 2019, at 22:31, Nakajima, Ju=
n &lt;<a href=3D"mailto:jun.nakajima@intel.com" class=3D"">jun.nakajima@int=
el.com</a>&gt; wrote:<br class=3D"">
<br class=3D"">
On 5/13/19, 7:43 AM, &quot;<a href=3D"mailto:kvm-owner@vger.kernel.org" cla=
ss=3D"">kvm-owner@vger.kernel.org</a> on behalf of Alexandre Chartre&quot; =
wrote:<br class=3D"">
<br class=3D"">
&nbsp;&nbsp;Proposal<br class=3D"">
&nbsp;&nbsp;=3D=3D=3D=3D=3D=3D=3D=3D<br class=3D"">
<br class=3D"">
&nbsp;&nbsp;To handle both these points, this series introduce the mechanis=
m of KVM<br class=3D"">
&nbsp;&nbsp;address space isolation. Note that this mechanism completes (a)=
&#43;(b) and<br class=3D"">
&nbsp;&nbsp;don't contradict. In case this mechanism is also applied, (a)&#=
43;(b) should<br class=3D"">
&nbsp;&nbsp;still be applied to the full virtual address space as a defence=
-in-depth).<br class=3D"">
<br class=3D"">
&nbsp;&nbsp;The idea is that most of KVM #VMExit handlers code will run in =
a special<br class=3D"">
&nbsp;&nbsp;KVM isolated address space which maps only KVM required code an=
d per-VM<br class=3D"">
&nbsp;&nbsp;information. Only once KVM needs to architectually access other=
 (sensitive)<br class=3D"">
&nbsp;&nbsp;data, it will switch from KVM isolated address space to full st=
andard<br class=3D"">
&nbsp;&nbsp;host address space. At this point, KVM will also need to kick a=
ll sibling<br class=3D"">
&nbsp;&nbsp;hyperthreads to get out of guest (note that kicking all sibling=
 hyperthreads<br class=3D"">
&nbsp;&nbsp;is not implemented in this serie).<br class=3D"">
<br class=3D"">
&nbsp;&nbsp;Basically, we will have the following flow:<br class=3D"">
<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;- qemu issues KVM_RUN ioctl<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;- KVM handles the ioctl and calls vcpu_run():<br cl=
ass=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;. KVM switches from the kernel address =
to the KVM address space<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;. KVM transfers control to VM (VMLAUNCH=
/VMRESUME)<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;. VM returns to KVM<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;. KVM handles VM-Exit:<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;. if handling need full ker=
nel then switch to kernel address space<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;. else continues with KVM a=
ddress space<br class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;. KVM loops in vcpu_run() or return<br =
class=3D"">
&nbsp;&nbsp;&nbsp;&nbsp;- KVM_RUN ioctl returns<br class=3D"">
<br class=3D"">
&nbsp;&nbsp;So, the KVM_RUN core function will mainly be executed using the=
 KVM address<br class=3D"">
&nbsp;&nbsp;space. The handling of a VM-Exit can require access to the kern=
el space<br class=3D"">
&nbsp;&nbsp;and, in that case, we will switch back to the kernel address sp=
ace.<br class=3D"">
<br class=3D"">
Once all sibling hyperthreads are in the host (either using the full kernel=
 address space or user address space), what happens to the other sibling hy=
perthreads if one of them tries to do VM entry? That VCPU will switch to th=
e KVM address space prior to VM
 entry, but others continue to run? Do you think (a) &#43; (b) would be suf=
ficient for that case?<br class=3D"">
</blockquote>
<br class=3D"">
The description here is missing and important part: When a hyperthread need=
s to switch from KVM isolated address space to kernel full address space, i=
t should first kick all sibling hyperthreads outside of guest and only then=
 safety switch to full kernel address
 space. Only once all sibling hyperthreads are running with KVM isolated ad=
dress space, it is safe to enter guest.<br class=3D"">
<br class=3D"">
</div>
</div>
</blockquote>
<div><br class=3D"">
</div>
<div>Okay, it makes sense. So, it will require some synchronization among t=
he siblings there.</div>
<br class=3D"">
<blockquote type=3D"cite" class=3D"">
<div class=3D"">
<div class=3D"">The main point of this address space is to avoid kicking al=
l sibling hyperthreads on *every* VMExit from guest but instead only kick t=
hem when switching address space. The assumption is that the vast majority =
of exits can be handled in KVM isolated
 address space and therefore do not require to kick the sibling hyperthread=
s outside of guest.<br class=3D"">
</div>
</div>
</blockquote>
<br class=3D"">
</div>
<div><br class=3D"">
</div>
<div class=3D""><span style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, =
0);" class=3D"">---</span><br style=3D"caret-color: rgb(0, 0, 0); color: rg=
b(0, 0, 0);" class=3D"">
<span style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0);" class=3D"">=
Jun</span><br style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0);" cla=
ss=3D"">
<span style=3D"caret-color: rgb(0, 0, 0); color: rgb(0, 0, 0);" class=3D"">=
Intel Open Source Technology Center</span></div>
</body>
</html>

--_000_D07C8F51F2DF4C8BAB3B0DFABD5F4C33intelcom_--

