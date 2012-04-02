Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id C88746B0044
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 13:10:33 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so1685142ghr.14
        for <linux-mm@kvack.org>; Mon, 02 Apr 2012 10:10:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C01454D13A6@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB9455FE2@USINDEVS02.corp.hds.com>
 <20120305215602.GA1693@redhat.com> <4F5798B1.5070005@jp.fujitsu.com>
 <65795E11DBF1E645A09CEC7EAEE94B9CB951A45F@USINDEVS02.corp.hds.com> <65795E11DBF1E645A09CEC7EAEE94B9C01454D13A6@USINDEVS02.corp.hds.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 2 Apr 2012 10:10:12 -0700
Message-ID: <CAHGf_=p9OgVC9J-Nh78CTbuMbc9CVt-+-G+CNbYUsgz70Uc8Qg@mail.gmail.com>
Subject: Re: [RFC][PATCH] avoid swapping out with swappiness==0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: "jweiner@redhat.com" <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "riel@redhat.com" <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>

2012/3/30 Satoru Moriya <satoru.moriya@hds.com>:
> Hello Kosaki-san,
>
> On 03/07/2012 01:18 PM, Satoru Moriya wrote:
>> On 03/07/2012 12:19 PM, KOSAKI Motohiro wrote:
>>> Thank you. I brought back to memory it. Unfortunately DB folks are
>>> still mainly using RHEL5 generation distros. At that time,
>>> swapiness=3D0 doesn't mean disabling swap.
>>>
>>> They want, "don't swap as far as kernel has any file cache page". but
>>> linux don't have such feature. then they used swappiness for emulate
>>> it. So, I think this patch clearly make userland harm. Because of, we
>>> don't have an alternative way.
>
> As I wrote in the previous mail(see below), with this patch
> the kernel begins to swap out when the sum of free pages and
> filebacked pages reduces less than watermark_high.
>
> So the kernel reclaims pages like following.
>
> nr_free + nr_filebacked >=3D watermark_high: reclaim only filebacked page=
s
> nr_free + nr_filebacked < =A0watermark_high: reclaim only anonymous pages

How?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
