Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 73E186B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 11:05:11 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id n128so44183560pfn.3
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 08:05:11 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTP id la16si10351936pab.64.2016.01.22.08.05.10
        for <linux-mm@kvack.org>;
        Fri, 22 Jan 2016 08:05:10 -0800 (PST)
Message-ID: <1453478706.2339.5.camel@HansenPartnership.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] VM containers
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Fri, 22 Jan 2016 08:05:06 -0800
In-Reply-To: <56A2511F.1080900@redhat.com>
References: <56A2511F.1080900@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, lsf-pc@lists.linuxfoundation.org
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>, KVM list <kvm@vger.kernel.org>

On Fri, 2016-01-22 at 10:56 -0500, Rik van Riel wrote:
> Hi,
> 
> I am trying to gauge interest in discussing VM containers at the
> LSF/MM
> summit this year. Projects like ClearLinux, Qubes, and others are all
> trying to use virtual machines as better isolated containers.
> 
> That changes some of the goals the memory management subsystem has,
> from "use all the resources effectively" to "use as few resources as
> necessary, in case the host needs the memory for something else".
> 
> These VMs could be as small as running just one application, so this
> goes a little further than simply trying to squeeze more virtual
> machines into a system with frontswap and cleancache.
> 
> Single-application VM sandboxes could also get their data
> differently,
> using (partial) host filesystem passthrough, instead of a virtual
> block device. This may change the relative utility of caching data
> inside the guest page cache, versus freeing up that memory and
> allowing the host to use it to cache things.
> 
> Are people interested in discussing this at LSF/MM, or is it better
> saved for a different forum?

Actually, I don't really think this is a container technology topic,
but I'm only objecting to the title not the content.  I don't know
Qubes, but I do know clearlinux ... it's VM based.  I think the
question that really needs answering is whether we can improve the
paravirt interfaces for memory control in VMs.  The biggest advantage
containers have over hypervisors is that the former know exactly what's
going on with the memory in the guests because of the shared kernel and
the latter have no real clue, because of the separate guest kernel
which only communicates with the host via hardware interfaces, which
leads to all sorts of bad scheduling decisions.

If I look at the current state of play, it looks like Hypervisors can
get an easy handle on file backed memory using the persistent memory
interfaces; that's how ClearLinux achieves its speed up today. 
 However, controlling guests under memory pressure requires us to have
a handle on the anonymous memory as well.  I really think a topic
exploring paravirt interfaces for anonymous memory would be really
useful.

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
