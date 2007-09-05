Message-ID: <46DF045F.4020806@qumranet.com>
Date: Wed, 05 Sep 2007 22:32:47 +0300
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC]: pte notifiers -- support for external page tables
References: <11890103283456-git-send-email-avi@qumranet.com> <46DEFDF4.5000900@redhat.com> <46DF0013.4060804@qumranet.com> <46DF0234.7090504@redhat.com>
In-Reply-To: <46DF0234.7090504@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, shaohua.li@intel.com, kvm-devel <kvm-devel@lists.sourceforge.net>, general@lists.openfabrics.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
>>
>> I imagine that many of the paravirt_ops mmu hooks will need to be 
>> exposed as pte notifiers.  This can't be done as part of the 
>> paravirt_ops code due to the need to pass high level data structures, 
>> though.
>
> Wait, I thought that paravirt_ops was all on the side of the
> guest kernel, where these host kernel operations are invisible?
>

It is, but the hooks are in much the same places.  It could be argued 
that you'd embed pte notifiers in paravirt_ops for a host kernel, but 
that's not doable because pte notifiers use higher-level data strutures 
(like vmas).

-- 
Any sufficiently difficult bug is indistinguishable from a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
