Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4E7A16B0352
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 05:31:48 -0400 (EDT)
Message-ID: <4C739178.1070405@redhat.com>
Date: Tue, 24 Aug 2010 12:31:36 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 11/12] Let host know whether the guest can handle async
 PF in non-userspace context.
References: <1279553462-7036-1-git-send-email-gleb@redhat.com> <1279553462-7036-12-git-send-email-gleb@redhat.com>
In-Reply-To: <1279553462-7036-12-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 07/19/2010 06:31 PM, Gleb Natapov wrote:
> If guest can detect that it runs in non-preemptable context it can
> handle async PFs at any time, so let host know that it can send async
> PF even if guest cpu is not in userspace.
>
> Acked-by: Rik van Riel<riel@redhat.com>
> Signed-off-by: Gleb Natapov<gleb@redhat.com>
> ---
>   arch/x86/include/asm/kvm_host.h |    1 +
>   arch/x86/include/asm/kvm_para.h |    1 +
>   arch/x86/kernel/kvm.c           |    3 +++
>   arch/x86/kvm/x86.c              |    5 +++--
>   4 files changed, 8 insertions(+), 2 deletions(-)
>
> diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
> index 45e6c12..c675d5d 100644
> --- a/arch/x86/include/asm/kvm_host.h
> +++ b/arch/x86/include/asm/kvm_host.h
> @@ -367,6 +367,7 @@ struct kvm_vcpu_arch {
>   	cpumask_var_t wbinvd_dirty_mask;
>
>   	u32 __user *apf_data;
> +	bool apf_send_user_only;
>   	u32 apf_memslot_ver;
>   	u64 apf_msr_val;
>   	u32 async_pf_id;

Lots of apf stuff in here.  Make it apg.data etc.?

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
