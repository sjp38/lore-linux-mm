Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 268366B0037
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 12:59:46 -0400 (EDT)
Message-ID: <51489979.2070403@draigBrady.com>
Date: Tue, 19 Mar 2013 16:59:37 +0000
From: =?UTF-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: kswapd craziness round 2
References: <5121C7AF.2090803@numascale-asia.com> <CAJd=RBArPT8YowhLuE8YVGNfH7G-xXTOjSyDgdV2RsatL-9m+Q@mail.gmail.com> <51254AD2.7000906@suse.cz> <CAJd=RBCiYof5rRVK+62OFMw+5F=5rS=qxRYF+OHpuRz895bn4w@mail.gmail.com> <512F8D8B.3070307@suse.cz> <CAJd=RBD=eT=xdEy+v3GBZ47gd47eB+fpF-3VtfpLAU7aEkZGgA@mail.gmail.com> <5138EC6C.6030906@suse.cz> <CAJd=RBC6JzXzPn9OV8UsbEjX152RcbKpuGGy+OBGM6E43gourQ@mail.gmail.com> <513A7263.5090303@suse.cz>
In-Reply-To: <513A7263.5090303@suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: Hillf Danton <dhillf@gmail.com>, Daniel J Blueman <daniel@numascale-asia.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Steffen Persvold <sp@numascale.com>, mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On 03/08/2013 11:21 PM, Jiri Slaby wrote:
> On 03/08/2013 07:42 AM, Hillf Danton wrote:
>> On Fri, Mar 8, 2013 at 3:37 AM, Jiri Slaby <jslaby@suse.cz> wrote:
>>> On 03/01/2013 03:02 PM, Hillf Danton wrote:
>>>> On Fri, Mar 1, 2013 at 1:02 AM, Jiri Slaby <jslaby@suse.cz> wrote:
>>>>>
>>>>> Ok, no difference, kswap is still crazy. I'm attaching the output of
>>>>> "grep -vw '0' /proc/vmstat" if you see something there.
>>>>>
>>>> Thanks to you for test and data.
>>>>
>>>> Lets try to restore the deleted nap, then.
>>>
>>> Oh, it seems to be nice now:
>>> root       579  0.0  0.0      0     0 ?        S    Mar04   0:13 [kswapd0]
>>>
>> Double thanks.
> 
> There is one downside. I'm not sure whether that patch was the culprit.
> My Thunderbird is jerky when scrolling and lags while writing this
> message. The letters sometimes appear later than typed and in groups. Like
> I (kbd): My Thunder
> TB: My Thunder
> I (kbd): b-i-r-d
> TB: is silent
> I (kbd): still typing...
> TB: bird is
> 
> Perhaps it's not only TB.

I notice the same thunderbird issue on the much older 2.6.40.4-5.fc15.x86_64
which I'd hoped would be fixed on upgrade :(

My Thunderbird is using 1957m virt, 722m RSS on my 3G system.
What are your corresponding mem values?

For reference:
http://marc.info/?t=130865025500001&r=1&w=2
https://bugzilla.redhat.com/show_bug.cgi?id=712019

thanks,
PA!draig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
