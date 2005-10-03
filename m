From: David Lang <david.lang@digitalinsight.com>
In-Reply-To: <86300000.1128353125@[10.10.2.4]>
References: dlang@dlang.diginsite.com <Pine.LNX.4.62.0510030802090.11541@qynat.qvtvafvgr.pbz> <83890000.1128352138@[10.10.2.4]> <Pine.LNX.4.62.0510030810290.11541@qynat.qvtvafvgr.pbz> <86300000.1128353125@[10.10.2.4]>
Date: Mon, 3 Oct 2005 08:32:47 -0700 (PDT)
Subject: Re: [PATCH 00/07][RFC] i386: NUMA emulation
In-Reply-To: <86300000.1128353125@[10.10.2.4]>
Message-ID: <Pine.LNX.4.62.0510030831550.11541@qynat.qvtvafvgr.pbz>
References: dlang@dlang.diginsite.com <Pine.LNX.4.62.0510030802090.11541@qynat.qvtvafvgr.pbz>
 <83890000.1128352138@[10.10.2.4]> <Pine.LNX.4.62.0510030810290.11541@qynat.qvtvafvgr.pbz>
 <86300000.1128353125@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Magnus Damm <magnus.damm@gmail.com>, Dave Hansen <haveblue@us.ibm.com>, Magnus Damm <magnus@valinux.co.jp>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 3 Oct 2005, Martin J. Bligh wrote:

> --David Lang <david.lang@digitalinsight.com> wrote (on Monday, October 03, 2005 08:13:09 -0700):
>
>> On Mon, 3 Oct 2005, Martin J. Bligh wrote:
>>
>>> --David Lang <david.lang@digitalinsight.com> wrote (on Monday, October 03, 2005 08:03:44 -0700):
>>>
>>>> On Mon, 3 Oct 2005, Martin J. Bligh wrote:
>>>>
>>>>> But that's not the same at all! ;-) PAE memory is the same speed as
>>>>> the other stuff. You just have a 3rd level of pagetables for everything.
>>>>> One could (correctly) argue it made *all* memory slower, but it does so
>>>>> in a uniform fashion.
>>>>
>>>> is it? I've seen during the memory self-test at boot that machines slow down noticably as they pass the 4G mark.
>>>
>>> Not noticed that, and I can't see why it should be the case in general,
>>> though I suppose some machines might be odd. Got any numbers?
>>
>> just the fact that the system boot memory test takes 3-4 times as long with 8G or ram then with 4G of ram. I then boot a 64 bit kernel on the system and never use PAE mode again :-)
>>
>> if you can point me at a utility that will test the speed of the memory in different chunks I'll do some testing on the Opteron systems I have available. unfortunantly I don't have any Xeon systems to test this on.
>
> Mmm. 64-bit uniproc systems, with > 4GB of RAM, running a 32 bit kernel
> don't really strike me as a huge market segment ;-)

true, but there are a lot of 32-bit uniproc systems sold by Intel that 
have (or can have) more then 4G of ram. These are the machines I was 
thinking of.

David Lang

-- 
There are two ways of constructing a software design. One way is to make it so simple that there are obviously no deficiencies. And the other way is to make it so complicated that there are no obvious deficiencies.
  -- C.A.R. Hoare

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
