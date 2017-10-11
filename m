Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 00AC36B0253
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 20:48:56 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v13so407170pgq.1
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 17:48:55 -0700 (PDT)
Received: from h3cmg01-ex.h3c.com (smtp.h3c.com. [60.191.123.56])
        by mx.google.com with ESMTP id z100si10174047plh.362.2017.10.10.17.48.54
        for <linux-mm@kvack.org>;
        Tue, 10 Oct 2017 17:48:54 -0700 (PDT)
From: Changwei Ge <ge.changwei@h3c.com>
Subject: Re: mmotm 2016-08-02-15-53 uploaded
Date: Wed, 11 Oct 2017 00:48:34 +0000
Message-ID: <63ADC13FD55D6546B7DECE290D39E373CED68187@H3CMLB14-EX.srv.huawei-3com.com>
References: <57a124aa.eJmVCvd1SOHlQ1X8%akpm@linux-foundation.org>
 <CAGF4SLgi6jgtxbqtTEjL8FGXUHHsSm6KeoVqANLt3LB6OTBboA@mail.gmail.com>
 <20171010123749.2c59f3b762b3c0b33e80a67d@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vitaly Mayatskih <v.mayatskih@gmail.com>
Cc: "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, "mhocko@suse.cz" <mhocko@suse.cz>, "broonie@kernel.org" <broonie@kernel.org>, "ocfs2-devel@oss.oracle.com" <ocfs2-devel@oss.oracle.com>, piaojun <piaojun@huawei.com>, Joseph Qi <joseph.qi@huawei.com>, Jiufei Xue <xuejiufei@huawei.com>, Mark Fasheh <mfasheh@suse.de>, Joel Becker <jlbec@evilplan.org>, Junxiao Bi <junxiao.bi@oracle.com>

Hi Andrew and Vitaly,=0A=
=0A=
I do agree that patch ee8f7fcbe638 ("ocfs2/dlm: continue to purge =0A=
recovery lockres when recovery master goes down", 2016-08-02) introduced =
=0A=
an issue. It makes DLM recovery can't pick up a new master for an =0A=
existed lock resource whose owner died seconds ago.=0A=
=0A=
But this patch truly solves another issue.=0A=
So I think we can't just revert this patch but to give a fix to it.=0A=
=0A=
Thanks,=0A=
Changwei=0A=
=0A=
On 2017/10/11 3:38, Andrew Morton wrote:=0A=
> On Tue, 10 Oct 2017 14:06:41 -0400 Vitaly Mayatskih <v.mayatskih@gmail.co=
m> wrote:=0A=
> =0A=
>> * ocfs2-dlm-continue-to-purge-recovery-lockres-when-recovery=0A=
>> -master-goes-down.patch=0A=
>>=0A=
>> This one completely broke two node cluster use case: when one node dies,=
=0A=
>> the other one either eventually crashes (~4.14-rc4) or locks up (pre-4.1=
4).=0A=
> =0A=
> Are you sure?=0A=
> =0A=
> Are you able to confirm that reverting this patch (ee8f7fcbe638b07e8)=0A=
> and only this patch fixes up current mainline kernels?=0A=
> =0A=
> Are you able to supply more info on the crashes and lockups so that the=
=0A=
> ocfs2 developers can understand the failures?=0A=
> =0A=
> Thanks.=0A=
> =0A=
=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
