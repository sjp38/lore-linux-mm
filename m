Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6FBF36B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 17:14:42 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ca5so265453507pac.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 14:14:42 -0700 (PDT)
Received: from mx0a-000ceb01.pphosted.com (mx0a-000ceb01.pphosted.com. [67.231.144.126])
        by mx.google.com with ESMTPS id d8si36912291paw.5.2016.08.01.14.14.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 14:14:41 -0700 (PDT)
Subject: Re: OOM killer changes
References: <20160801061625.GA11623@dhcp22.suse.cz>
 <b1a39756-a0b5-1900-6575-d6e1f502cb26@Quantum.com>
 <20160801182358.GB31957@dhcp22.suse.cz>
 <30dbabc4-585c-55a5-9f3a-4e243c28356a@Quantum.com>
 <20160801192620.GD31957@dhcp22.suse.cz>
 <939def12-3fa8-e877-ce17-b59db9fa1876@Quantum.com>
 <20160801194323.GE31957@dhcp22.suse.cz>
 <d8116023-dcd4-8763-af77-f2889f84cdb6@Quantum.com>
 <20160801200926.GF31957@dhcp22.suse.cz>
 <3c022d92-9c96-9022-8496-aa8738fb7358@quantum.com>
 <20160801202616.GG31957@dhcp22.suse.cz>
From: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Message-ID: <b91f97ee-c369-43be-c934-f84b96260ead@Quantum.com>
Date: Mon, 1 Aug 2016 14:14:37 -0700
MIME-Version: 1.0
In-Reply-To: <20160801202616.GG31957@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On 01.08.2016 13:26, Michal Hocko wrote:
>
>> sdc, sdd and sde each at max speed, with a little bit of garden variety IO
>> on sda and sdb.
> So do I get it right that the majority of the IO is to those slower USB
> disks?  If yes then does lowering the dirty_bytes to something smaller
> help?

Yes, the vast majority.

I set dirty_bytes to 128MiB and started a fairly IO and memory intensive 
process and the OOM killer kicked in within a few seconds.

Same with 16MiB dirty_bytes and 1MiB.

Some additional IO load from my fast subsystem is enough:

At 1MiB dirty_bytes,

find /btrfs0/ -type f -exec md5sum {} \;

was enough (where /btrfs0 is on a LVM2 LV and the PV is on sda.) It read 
a few dozen files (random stuff with very mixed file sizes, none very 
big) until the OOM killer kicked in.

I'll try 4.6.


Ralf-Peter


----------------------------------------------------------------------
The information contained in this transmission may be confidential. Any disclosure, copying, or further distribution of confidential information is not permitted unless such privilege is explicitly granted in writing by Quantum. Quantum reserves the right to have electronic communications, including email and attachments, sent across its networks filtered through anti virus and spam software programs and retain such messages in order to comply with applicable data security and retention requirements. Quantum is not responsible for the proper and complete transmission of the substance of this communication or for any delay in its receipt.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
