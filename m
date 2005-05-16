Received: from ram.rentec.com (mailhost [192.5.35.66])
	by unicorn.rentec.com (8.13.1/8.12.1) with ESMTP id j4GG6nLF026821
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Mon, 16 May 2005 12:06:50 -0400 (EDT)
Message-ID: <4288C518.4000002@rentec.com>
Date: Mon, 16 May 2005 12:06:48 -0400
From: Wolfgang Wander <wwc@rentec.com>
MIME-Version: 1.0
Subject: Re: [OOPS] 2.6.12-rc4-mm1 check_nmi_watchdog
References: <17028.63457.959340.362443@gargle.gargle.HOWL>
In-Reply-To: <17028.63457.959340.362443@gargle.gargle.HOWL>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Wolfgang Wander <wwc@rentec.com>
List-ID: <linux-mm.kvack.org>

Just for completeness - this issue is fixed for me in rc4-mm2. Thanks!

Wolfgang Wander wrote:

>I know it has been reported before,  just another datapoint (and offer
>to test possible fixes)...
>
>During boot on a dual x86_64 I see the following message 
>(typed - hopefully correct - from a screen shot):
>  --------------------
>Testing NMI watchdog ... <3>BUG: soft lockup detected on CPU#1!
>
>Mudules linked in:
>Pid: 1, comm: swapper Not tainted 2.6.12-rc4-mm1
>RIP: 0010:[<ffffffff802180d6>] <ffffffff802180d6>{__delay+6}
>RSP: 0000:ffff8100fbf01f00  EFLAGS: 00000283
>RAX: 00000000000badf8 RBX: ffffffff803e34d8 RCX: 00000000ca6fb23c
>RDX: 0000000000000036 RSI: 0000000000000000 RDI: 00000000001e6928
>RBP: ffffffff803ff3c0 R08: 0000000000000720 R09: 0000000000000000
>R10: 00000000ffffffff R11: 0000000000000001 R12: 0000000000000002
>R13: ffff8100fbf00000 R14: ffff810100000000 R15: 0000000000000002
>FS:  0000000000000000(0000) GS:ffffffff804dd900(0000) knlGS: 0000000000000000
>CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
>CR2: 0000000000000000 CR3: 0000000000101000 CR4: 00000000000006e0
>
>Call Trace:<ffffffff804f63a0>{check_nmi_watchdog+192} <ffffffff8010b24a>{init+506}
>       <ffffffff8010e7cb>{child_rip+8} <ffffffff8010b050>{init+0}
>       <ffffffff8010e7c3>{child_rip+0}
>CPU#2: NMI appears to be stuck (0)!
>  --------------------
>
>2.6.11.[0-8] and 2.6.12-rc4 are ok.
>  
>
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
