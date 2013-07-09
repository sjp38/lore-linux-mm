Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 95AE56B0031
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 12:01:49 -0400 (EDT)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Tue, 9 Jul 2013 16:56:09 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 60F0D2190068
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 17:05:37 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r69G1YnJ53870712
	for <linux-mm@kvack.org>; Tue, 9 Jul 2013 16:01:34 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r69G1iRa007666
	for <linux-mm@kvack.org>; Tue, 9 Jul 2013 10:01:45 -0600
Message-ID: <51DC33E7.1030404@de.ibm.com>
Date: Tue, 09 Jul 2013 18:01:43 +0200
From: Christian Borntraeger <borntraeger@de.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] PF: Provide additional direct page notification
References: <1373378207-10451-1-git-send-email-dingel@linux.vnet.ibm.com> <1373378207-10451-4-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1373378207-10451-4-git-send-email-dingel@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Alexander Graf <agraf@suse.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/07/13 15:56, Dominik Dingel wrote:
> By setting a Kconfig option, the architecture can control when
> guest notifications will be presented by the apf backend.
> So there is the default batch mechanism, working as before, where the vcpu thread
> should pull in this information. On the other hand there is now the direct
> mechanism, this will directly push the information to the guest.
> 
> Still the vcpu thread should call check_completion to cleanup leftovers,
> that leaves most of the common code untouched.
> 
> Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>

Acked-by: Christian Borntraeger <borntraeger@de.ibm.com> 
for the "why". We want to use the existing architectured interface.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
