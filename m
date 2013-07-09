Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id F361B6B0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 11:43:46 -0400 (EDT)
Date: Tue, 9 Jul 2013 18:43:35 +0300
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH 1/4] PF: Add FAULT_FLAG_RETRY_NOWAIT for guest fault
Message-ID: <20130709154335.GI24941@redhat.com>
References: <1373378207-10451-1-git-send-email-dingel@linux.vnet.ibm.com>
 <1373378207-10451-2-git-send-email-dingel@linux.vnet.ibm.com>
 <20130709152346.GG24941@redhat.com>
 <51DC2E0E.1050309@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51DC2E0E.1050309@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Dominik Dingel <dingel@linux.vnet.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Alexander Graf <agraf@suse.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 09, 2013 at 05:36:46PM +0200, Christian Borntraeger wrote:
> On 09/07/13 17:23, Gleb Natapov wrote:
> > On Tue, Jul 09, 2013 at 03:56:44PM +0200, Dominik Dingel wrote:
> >> In case of a fault retry exit sie64() with gmap_fault indication for the
> >> running thread set. This makes it possible to handle async page faults
> >> without the need for mm notifiers.
> >>
> >> Based on a patch from Martin Schwidefsky.
> >>
> > For that we will obviously need Christian and Cornelia ACKs. Or it can
> > go in via S390 tree.
> > 
> 
> >> Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
> Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>
> 
> Do you want me or Conny to apply these patches add a signoff and resend them?
> Otherwise I will review the s390 specific patches and ack them individually.
> 
If your are OK with me merging this one through kvm.git then just
ack/review all others. I have a small comment on patch 2, but otherwise
the patch series looks OK to me from KVM perspective.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
