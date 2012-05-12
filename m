Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 5C2776B004D
	for <linux-mm@kvack.org>; Sat, 12 May 2012 18:21:20 -0400 (EDT)
Message-ID: <4FAEE256.7000403@redhat.com>
Date: Sat, 12 May 2012 18:21:10 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] avoid swapping out with swappiness==0
References: <65795E11DBF1E645A09CEC7EAEE94B9CB9455FE2@USINDEVS02.corp.hds.com> <20120305215602.GA1693@redhat.com> <4F5798B1.5070005@jp.fujitsu.com> <65795E11DBF1E645A09CEC7EAEE94B9CB951A45F@USINDEVS02.corp.hds.com> <65795E11DBF1E645A09CEC7EAEE94B9C01454D13A6@USINDEVS02.corp.hds.com> <CAHGf_=p9OgVC9J-Nh78CTbuMbc9CVt-+-G+CNbYUsgz70Uc8Qg@mail.gmail.com> <4F7ADE1A.2050004@redhat.com> <4F7C870B.6020807@gmail.com> <65795E11DBF1E645A09CEC7EAEE94B9C014575D8CF@USINDEVS02.corp.hds.com> <65795E11DBF1E645A09CEC7EAEE94B9C01583B4D7C@USINDEVS02.corp.hds.com>
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C01583B4D7C@USINDEVS02.corp.hds.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>

On 05/11/2012 05:11 PM, Satoru Moriya wrote:
> On 04/20/2012 08:21 PM, Satoru Moriya wrote:
>> Ah yes, it is not so small now.
>> On 4GB server, without THP min_free_kbytes is 8113 but with THP it is
>> 67584.
>>
>> How about using low watermark or min watermark?
>> Are they still big?
>>
>> ...or should we use other value?
>
> What do you think of the idea above?

I believe that using the high watermark is just fine.

We want to start swapping, before the page cache is so
small that we start thrashing from that.

> So, I propose that we start with applying this patch first
> and then discuss/improve the threshold.
>
> The patch may not be perfect but, at least, we can improve
> the kernel behavior in the enough filebacked memory case
> with this patch. I believe it's better than nothing.

Agreed.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
