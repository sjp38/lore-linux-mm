Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 47DD86B0311
	for <linux-mm@kvack.org>; Sun,  9 Jul 2017 23:10:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id g7so104110383pgp.1
        for <linux-mm@kvack.org>; Sun, 09 Jul 2017 20:10:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b23si7021034pfj.228.2017.07.09.20.10.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jul 2017 20:10:21 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6A39GhW063943
	for <linux-mm@kvack.org>; Sun, 9 Jul 2017 23:10:20 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bjukqbvus-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 09 Jul 2017 23:10:20 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 10 Jul 2017 13:10:18 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6A3902I16777222
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:09:00 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6A38p9F006604
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:08:52 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: Re: [RFC v5 33/38] powerpc: Deliver SEGV signal on pkey violation
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-34-git-send-email-linuxram@us.ibm.com>
Date: Mon, 10 Jul 2017 08:38:53 +0530
MIME-Version: 1.0
In-Reply-To: <1499289735-14220-34-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <4cbcc16c-7597-7aa1-ddea-b6bef25df11b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On 07/06/2017 02:52 AM, Ram Pai wrote:
> The value of the AMR register at the time of exception
> is made available in gp_regs[PT_AMR] of the siginfo.
> 
> The value of the pkey, whose protection got violated,
> is made available in si_pkey field of the siginfo structure.
> 
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  arch/powerpc/include/uapi/asm/ptrace.h |    3 ++-
>  arch/powerpc/kernel/signal_32.c        |    5 +++++
>  arch/powerpc/kernel/signal_64.c        |    4 ++++
>  arch/powerpc/kernel/traps.c            |   14 ++++++++++++++
>  4 files changed, 25 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/powerpc/include/uapi/asm/ptrace.h b/arch/powerpc/include/uapi/asm/ptrace.h
> index 8036b38..7ec2428 100644
> --- a/arch/powerpc/include/uapi/asm/ptrace.h
> +++ b/arch/powerpc/include/uapi/asm/ptrace.h
> @@ -108,8 +108,9 @@ struct pt_regs {
>  #define PT_DAR	41
>  #define PT_DSISR 42
>  #define PT_RESULT 43
> -#define PT_DSCR 44
>  #define PT_REGS_COUNT 44
> +#define PT_DSCR 44
> +#define PT_AMR	45

Why PT_DSCR was moved down ? This change is redundant here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
