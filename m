Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D01B6B02EE
	for <linux-mm@kvack.org>; Tue,  2 May 2017 21:41:12 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 7so20428799pgg.19
        for <linux-mm@kvack.org>; Tue, 02 May 2017 18:41:12 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id x15si17676659pgo.301.2017.05.02.18.41.10
        for <linux-mm@kvack.org>;
        Tue, 02 May 2017 18:41:11 -0700 (PDT)
Subject: Re: 4.11.0-rc8+/x86_64 desktop lockup until applications closed
References: <md5:RQiZYAYNN/yJzTrY48XZ7w==>
 <ccd5aac8-b24a-713a-db54-c35688905595@internode.on.net>
 <20170427092636.GD4706@dhcp22.suse.cz>
 <99a78105-de58-a5e1-5191-d5f4de7ed5f4@internode.on.net>
 <20170502073138.GA14593@dhcp22.suse.cz>
From: Arthur Marsh <arthur.marsh@internode.on.net>
Message-ID: <73bb8828-e586-0aee-506b-5a7b6f87384a@internode.on.net>
Date: Wed, 3 May 2017 11:11:01 +0930
MIME-Version: 1.0
In-Reply-To: <20170502073138.GA14593@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org



Michal Hocko wrote on 02/05/17 17:01:

>> [92311.944443] swap_info_get: Bad swap offset entry 000ffffd
>> [92311.944449] swap_info_get: Bad swap offset entry 000ffffe
>> [92311.944451] swap_info_get: Bad swap offset entry 000fffff
>
> Pte swap entry seem to be clobbered. That suggests a deeper problem and
> a memory corruption.

Thanks again for the feedback. I've gone with 4.11.0+ git head kernels 
and last night rather than a lock-up I saw:

[40050.937161] mmap: chromium (6060): VmData 2148573184 exceed data 
ulimit 2147483647. Update limits or use boot option ignore_rlimit_data.
[40051.183213] traps: chromium[6060] trap int3 ip:5642ccce7996 
sp:7ffe0a563ac0 error:0

and the desktop session remained responsive.

The 2 GiB ulimit is preferable for me than having to rely on the OOM 
killer, but I can run tests with ignore_rlimit_data later on to check 
that the OOM killer still works rather than hitting some unforeseen 
error on swap exhaustion.

Arthur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
