Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id A9EE66B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 08:35:47 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l66so54789532wml.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 05:35:47 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id w77si11099336wme.5.2016.01.29.05.35.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 05:35:46 -0800 (PST)
Received: by mail-wm0-x22d.google.com with SMTP id p63so68452958wmp.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 05:35:46 -0800 (PST)
Date: Fri, 29 Jan 2016 14:35:38 +0100
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [LSF/MM ATTEND] HMM (heterogeneous memory manager) and GPU
Message-ID: <20160129133537.GA26044@gmail.com>
References: <20160128175536.GA20797@gmail.com>
 <20160129095028.GA10767@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20160129095028.GA10767@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jan 29, 2016 at 11:50:28AM +0200, Kirill A. Shutemov wrote:
> On Thu, Jan 28, 2016 at 06:55:37PM +0100, Jerome Glisse wrote:
> > Hi,
> > 
> > I would like to attend LSF/MM this year to discuss about HMM
> > (Heterogeneous Memory Manager) and more generaly all topics
> > related to GPU and heterogeneous memory architecture (including
> > persistent memory).
> 
> How is persistent memory heterogeneous?
> 
> I thought it's either in the same cache coherency domain (DAX case) or is
> not a memory for kernel -- behind block layer.
> Do we have yet another option?


Right now it is not, but i am interested in the DMA mapping issue. But from
what i have seen on roadmap, we are going toward a world with a deeper memory
hierarchy. Very fast cache near CPU in GB range, regular memory like ddr,
slower persistent or similar but with enormous capacity. On top of this you
have thing like GPU memory (which is my main topic of interest) and other
similar thing like FPGA. GPU are not going away, bandwidth for GPU is in TB/s
ranges and on GPU roadmap the gap with CPU memory bandwidth keeps getting
bigger.

So i believe this hierarchy of memory add a layer of complexity on top of
numa. Technology is not ready but it might be worth discussing it, seeing
if there is anything to do on top of numa.

Also note that thing like GPU memory can either be visible or unvisible from
CPU point of view, more over it can be cache coherent or not. Thought the
latter is only enabled through specific API where application is aware that
it loose cache coherency with CPU.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
