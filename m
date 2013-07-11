Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 639316B0038
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 06:58:31 -0400 (EDT)
Date: Thu, 11 Jul 2013 13:58:22 +0300
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH 4/4] PF: Async page fault support on s390
Message-ID: <20130711105822.GI8575@redhat.com>
References: <1373461195-27628-1-git-send-email-dingel@linux.vnet.ibm.com>
 <1373461195-27628-5-git-send-email-dingel@linux.vnet.ibm.com>
 <20130711090411.GA8575@redhat.com>
 <51DE8BE1.8000902@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51DE8BE1.8000902@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Dominik Dingel <dingel@linux.vnet.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Alexander Graf <agraf@suse.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jul 11, 2013 at 12:41:37PM +0200, Christian Borntraeger wrote:
> On 11/07/13 11:04, Gleb Natapov wrote:
> > On Wed, Jul 10, 2013 at 02:59:55PM +0200, Dominik Dingel wrote:
> >> This patch enables async page faults for s390 kvm guests.
> >> It provides the userspace API to enable, disable or get the status of this
> >> feature. Also it includes the diagnose code, called by the guest to enable
> >> async page faults.
> >>
> >> The async page faults will use an already existing guest interface for this
> >> purpose, as described in "CP Programming Services (SC24-6084)".
> >>
> >> Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
> > Christian, looks good now?
> 
> Looks good, but I just had a  discussion with Dominik about several other cases 
> (guest driven reboot, qemu driven reboot, life migration). This patch should 
> allow all these cases (independent from this patch we need an ioctl to flush the
> list of pending interrupts to do so, but reboot is currently broken in that
> regard anyway - patch is currently being looked at)
> 
> We are currently discussion if we should get rid of the APF_STATUS and let 
> the kernel wait for outstanding page faults before returning from KVM_RUN
> or if we go with this patch and let userspace wait for completion. 
> 
> Will discuss this with Dominik, Conny and Alex. So lets defer that till next
> week, ok?
> 
Sure.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
