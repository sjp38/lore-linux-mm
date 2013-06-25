Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 70D016B0032
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 03:26:47 -0400 (EDT)
Message-ID: <51C945FE.2030305@asianux.com>
Date: Tue, 25 Jun 2013 15:25:50 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [Suggestion] arch: s390: mm: the warnings with allmodconfig and
 "EXTRA_CFLAGS=-W"
References: <51C8F685.6000209@asianux.com> <51C8F861.9010101@asianux.com> <20130625085006.01a7f368@mschwide>
In-Reply-To: <20130625085006.01a7f368@mschwide>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, cornelia.huck@de.ibm.com, mtosatti@redhat.com, Thomas Gleixner <tglx@linutronix.de>, linux-s390@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, linux-mm@kvack.org

On 06/25/2013 02:50 PM, Martin Schwidefsky wrote:
> On Tue, 25 Jun 2013 09:54:41 +0800
> Chen Gang <gang.chen@asianux.com> wrote:
> 
>> > Hello Maintainers:
>> > 
>> > When allmodconfig for " IBM zSeries model z800 and z900"
>> > 
>> > It will report the related warnings ("EXTRA_CFLAGS=-W"):
>> >   mm/slub.c:1875:1: warning: a??deactivate_slaba?? uses dynamic stack allocation [enabled by default]
>> >   mm/slub.c:1941:1: warning: a??unfreeze_partials.isra.32a?? uses dynamic stack allocation [enabled by default]
>> >   mm/slub.c:2575:1: warning: a??__slab_freea?? uses dynamic stack allocation [enabled by default]
>> >   mm/slub.c:1582:1: warning: a??get_partial_node.isra.34a?? uses dynamic stack allocation [enabled by default]
>> >   mm/slub.c:2311:1: warning: a??__slab_alloc.constprop.42a?? uses dynamic stack allocation [enabled by default]
>> > 
>> > Is it OK ?
> Yes, these warnings should be ok. They are enabled by CONFIG_WARN_DYNAMIC_STACK,
> the purpose is to find all functions with dynamic stack allocations. The check
> if the allocations are truly ok needs to be done manually as the compiler
> can not find out the maximum allocation size automatically.

Thank you very much for your details information.

-- 
Chen Gang

Asianux Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
