Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B4B026B004F
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 01:46:51 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 4so1491924ywq.26
        for <linux-mm@kvack.org>; Mon, 20 Apr 2009 22:47:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090421101855.F10D.A69D9226@jp.fujitsu.com>
References: <20090418154207.1260.A69D9226@jp.fujitsu.com>
	 <alpine.DEB.1.10.0904201300140.1585@qirst.com>
	 <20090421101855.F10D.A69D9226@jp.fujitsu.com>
Date: Tue, 21 Apr 2009 08:47:35 +0300
Message-ID: <84144f020904202247y59e991abta7be65749814f46c@mail.gmail.com>
Subject: Re: AIM9 from 2.6.22 to 2.6.29
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

On Tue, Apr 21, 2009 at 4:20 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Sat, 18 Apr 2009, KOSAKI Motohiro wrote:
>>
>> > > Here is a list of AIM9 results for all kernels between 2.6.22 2.6.29:
>> > >
>> > > Significant regressions:
>> > >
>> > > creat-clo
>> > > page_test
>> >
>> > I'm interest to it.
>> > How do I get AIM9 benchmark?
>>
>> Checkout reaim9 on sourceforge.
>
> sourceforge search engine don't search reaim9 ;)
>
>
> http://sourceforge.net/search/?words=aim9&type_of_search=soft&pmode=0&words=reaim9&Search=Search

I can only find "reaim7" so maybe Christoph meant the aim9 suite here:

  http://aimbench.sourceforge.net/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
