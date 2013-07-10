Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id CF3376B0036
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 06:49:24 -0400 (EDT)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 10 Jul 2013 11:46:48 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id BFFBC1B0805F
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 11:49:20 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6AAn9Kx57606384
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 10:49:09 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6AAnJFi011768
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 04:49:19 -0600
Message-ID: <51DD3C2E.50409@de.ibm.com>
Date: Wed, 10 Jul 2013 12:49:18 +0200
From: Christian Borntraeger <borntraeger@de.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] PF: Provide additional direct page notification
References: <1373378207-10451-1-git-send-email-dingel@linux.vnet.ibm.com> <1373378207-10451-4-git-send-email-dingel@linux.vnet.ibm.com> <51DC33E7.1030404@de.ibm.com> <282EB214-206B-4A04-9830-D97679C9F4EC@suse.de>
In-Reply-To: <282EB214-206B-4A04-9830-D97679C9F4EC@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Graf <agraf@suse.de>
Cc: Dominik Dingel <dingel@linux.vnet.ibm.com>, Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/07/13 12:39, Alexander Graf wrote:
> 
> On 09.07.2013, at 18:01, Christian Borntraeger wrote:
> 
>> On 09/07/13 15:56, Dominik Dingel wrote:
>>> By setting a Kconfig option, the architecture can control when
>>> guest notifications will be presented by the apf backend.
>>> So there is the default batch mechanism, working as before, where the vcpu thread
>>> should pull in this information. On the other hand there is now the direct
>>> mechanism, this will directly push the information to the guest.
>>>
>>> Still the vcpu thread should call check_completion to cleanup leftovers,
>>> that leaves most of the common code untouched.
>>>
>>> Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
>>
>> Acked-by: Christian Borntraeger <borntraeger@de.ibm.com> 
>> for the "why". We want to use the existing architectured interface.
> 
> Shouldn't this be a runtime option?

This is an a) or b) depending on the architecture. So making this a kconfig
option is the most sane approach no?

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
