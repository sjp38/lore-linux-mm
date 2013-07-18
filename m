Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 4FF976B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 10:12:31 -0400 (EDT)
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 18 Jul 2013 15:07:55 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 60F6F17D8025
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 15:14:04 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6IECFcm52166752
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 14:12:15 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6IECPFC020641
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 08:12:25 -0600
Message-ID: <51E7F7C8.9090506@de.ibm.com>
Date: Thu, 18 Jul 2013 16:12:24 +0200
From: Christian Borntraeger <borntraeger@de.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] PF: Async page fault support on s390
References: <1373461195-27628-1-git-send-email-dingel@linux.vnet.ibm.com> <1373461195-27628-5-git-send-email-dingel@linux.vnet.ibm.com> <20130711090411.GA8575@redhat.com> <51DE8BE1.8000902@de.ibm.com> <51E7F440.2010600@redhat.com>
In-Reply-To: <51E7F440.2010600@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Gleb Natapov <gleb@redhat.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Alexander Graf <agraf@suse.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 18/07/13 15:57, Paolo Bonzini wrote:
> Il 11/07/2013 12:41, Christian Borntraeger ha scritto:
>> On 11/07/13 11:04, Gleb Natapov wrote:
>>> On Wed, Jul 10, 2013 at 02:59:55PM +0200, Dominik Dingel wrote:
>>>> This patch enables async page faults for s390 kvm guests.
>>>> It provides the userspace API to enable, disable or get the status of this
>>>> feature. Also it includes the diagnose code, called by the guest to enable
>>>> async page faults.
>>>>
>>>> The async page faults will use an already existing guest interface for this
>>>> purpose, as described in "CP Programming Services (SC24-6084)".
>>>>
>>>> Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
>>> Christian, looks good now?
>>
>> Looks good, but I just had a  discussion with Dominik about several other cases 
>> (guest driven reboot, qemu driven reboot, life migration). This patch should 
>> allow all these cases (independent from this patch we need an ioctl to flush the
>> list of pending interrupts to do so, but reboot is currently broken in that
>> regard anyway - patch is currently being looked at)
>>
>> We are currently discussion if we should get rid of the APF_STATUS and let 
>> the kernel wait for outstanding page faults before returning from KVM_RUN
>> or if we go with this patch and let userspace wait for completion. 
>>
>> Will discuss this with Dominik, Conny and Alex. So lets defer that till next
>> week, ok?
> 
> Let us know if we should wait for a v5. :)

Yes, there will be a v5


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
