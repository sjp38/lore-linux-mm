Message-ID: <46240888.1040804@redhat.com>
Date: Mon, 16 Apr 2007 19:36:40 -0400
From: Chuck Ebbert <cebbert@redhat.com>
MIME-Version: 1.0
Subject: Re: BUG:  Bad page state errors during kernel make
References: <4622EDD3.9080103@zachcarter.com> <20070416035603.GD21217@redhat.com> <46230A3A.8060907@zachcarter.com>
In-Reply-To: <46230A3A.8060907@zachcarter.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zach Carter <linux@zachcarter.com>
Cc: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Zach Carter wrote:
> 
> Dave Jones wrote:
>> On Sun, Apr 15, 2007 at 08:30:27PM -0700, Zach Carter wrote:
>>  > list_del corruption. prev->next should be c21a4628, but was e21a4628
>>
>> 'c' became 'e' in that last address. A single bit flipped.
>> Given you've had this for some time, this smells like a hardware problem.
>> memtest86+ will probably show up something.
> 
> Hum.   I forgot to mention in my report that I had already run thru 10
> clean passes with memtest86+
> 
> Do you think there might be other bad hw, or another explanation?

memtest86 does not really stress everything a real kernel compile
would.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
