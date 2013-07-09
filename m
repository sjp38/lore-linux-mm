Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 058BE6B0031
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 11:36:52 -0400 (EDT)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Tue, 9 Jul 2013 16:31:37 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4050F17D805A
	for <linux-mm@kvack.org>; Tue,  9 Jul 2013 16:38:22 +0100 (BST)
Received: from d06av05.portsmouth.uk.ibm.com (d06av05.portsmouth.uk.ibm.com [9.149.37.229])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r69FaaZd55181436
	for <linux-mm@kvack.org>; Tue, 9 Jul 2013 15:36:37 GMT
Received: from d06av05.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av05.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r69FalQC007226
	for <linux-mm@kvack.org>; Tue, 9 Jul 2013 09:36:47 -0600
Message-ID: <51DC2E0E.1050309@de.ibm.com>
Date: Tue, 09 Jul 2013 17:36:46 +0200
From: Christian Borntraeger <borntraeger@de.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] PF: Add FAULT_FLAG_RETRY_NOWAIT for guest fault
References: <1373378207-10451-1-git-send-email-dingel@linux.vnet.ibm.com> <1373378207-10451-2-git-send-email-dingel@linux.vnet.ibm.com> <20130709152346.GG24941@redhat.com>
In-Reply-To: <20130709152346.GG24941@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>
Cc: Dominik Dingel <dingel@linux.vnet.ibm.com>, Paolo Bonzini <pbonzini@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Alexander Graf <agraf@suse.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/07/13 17:23, Gleb Natapov wrote:
> On Tue, Jul 09, 2013 at 03:56:44PM +0200, Dominik Dingel wrote:
>> In case of a fault retry exit sie64() with gmap_fault indication for the
>> running thread set. This makes it possible to handle async page faults
>> without the need for mm notifiers.
>>
>> Based on a patch from Martin Schwidefsky.
>>
> For that we will obviously need Christian and Cornelia ACKs. Or it can
> go in via S390 tree.
> 

>> Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>

Do you want me or Conny to apply these patches add a signoff and resend them?
Otherwise I will review the s390 specific patches and ack them individually.

Christian



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
