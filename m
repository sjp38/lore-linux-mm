Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 6D6BA6B0037
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 21:47:56 -0400 (EDT)
Message-ID: <5153A1C7.6030409@cn.fujitsu.com>
Date: Thu, 28 Mar 2013 09:49:59 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kernel/range.c: subtract_range: fix the broken phrase
 issued by printk
References: <CAE9FiQUrt11A0YAOLgvv3uTAWtTvVg3Mho9eD53orbxW6Jd8Vg@mail.gmail.com> <1363665251-14377-1-git-send-email-linfeng@cn.fujitsu.com> <CAErSpo6DWfHii8d8rGPJ1dLj5TVzsgU7QGDoAvBM5Fb_N5=mtw@mail.gmail.com>
In-Reply-To: <CAErSpo6DWfHii8d8rGPJ1dLj5TVzsgU7QGDoAvBM5Fb_N5=mtw@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "x86@kernel.org" <x86@kernel.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Yinghai Lu <yinghai@kernel.org>

Hi Bjorn and others,

On 03/28/2013 01:27 AM, Bjorn Helgaas wrote:
>> -                               printk(KERN_ERR "run of slot in ranges\n");
>> > +                               pr_err("%s: run out of slot in ranges\n",
>> > +                                       __func__);
>> >                         }
>> >                         range[j].end = start;
>> >                         continue;
> So now the user might see:
> 
>     subtract_range: run out of slot in ranges
> 
> What is the user supposed to do when he sees that?  If he happens to
> mention it on LKML, what are we going to do about it?  If he attaches
> the complete dmesg log, is there enough information to do something?
> 
> IMHO, that message is still totally useless.
> 

Yes, we need to issue some useful message. 
How about dump_stack() there so that we can find some clues more since
subtract_range() is called mtrr_bp_init path and pci relative path, then
it may help to instruct us to do something ;-) ?

thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
