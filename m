Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BE4936B0055
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 03:57:32 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so233341yxh.26
        for <linux-mm@kvack.org>; Tue, 28 Apr 2009 00:58:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1240904919.7620.73.camel@twins>
References: <20090428044426.GA5035@eskimo.com>
	 <20090428143019.EBBF.A69D9226@jp.fujitsu.com>
	 <1240904919.7620.73.camel@twins>
Date: Tue, 28 Apr 2009 13:28:25 +0530
Message-ID: <661de9470904280058ub16c66bi6a52d36ca4c2d52c@mail.gmail.com>
Subject: Re: Swappiness vs. mmap() and interactive response
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Elladan <elladan@eskimo.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 28, 2009 at 1:18 PM, Peter Zijlstra <peterz@infradead.org> wrot=
e:
> On Tue, 2009-04-28 at 14:35 +0900, KOSAKI Motohiro wrote:
>> (cc to linux-mm and Rik)
>>
>>
>> > Hi,
>> >
>> > So, I just set up Ubuntu Jaunty (using Linux 2.6.28) on a quad core ph=
enom box,
>> > and then I did the following (with XFS over LVM):
>> >
>> > mv /500gig/of/data/on/disk/one /disk/two
>> >
>> > This quickly caused the system to. grind.. to... a.... complete..... h=
alt.
>> > Basically every UI operation, including the mouse in Xorg, started exp=
eriencing
>> > multiple second lag and delays. =A0This made the system essentially un=
usable --
>> > for example, just flipping to the window where the "mv" command was ru=
nning
>> > took 10 seconds on more than one occasion. =A0Basically a "click and g=
et coffee"
>> > interface.
>>
>> I have some question and request.
>>
>> 1. please post your /proc/meminfo
>> 2. Do above copy make tons swap-out? IOW your disk read much faster than=
 write?
>> 3. cache limitation of memcgroup solve this problem?
>> 4. Which disk have your /bin and /usr/bin?
>>
>
> FWIW I fundamentally object to 3 as being a solution.
>

memcgroup were not created to solve latency problems, but they do
isolate memory and if that helps latency, I don't see why that is a
problem. I don't think isolating applications that we think are not
important and interfere or consume more resources than desired is a
bad solution.

> I still think the idea of read-ahead driven drop-behind is a good one,
> alas last time we brought that up people thought differently.

I vaguely remember the patches, but can't recollect the details.

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
