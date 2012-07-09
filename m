Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 9574A6B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 17:21:10 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so24005137pbb.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 14:21:09 -0700 (PDT)
Date: Mon, 9 Jul 2012 14:21:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/buddy: more comments for skip_free_areas_node()
In-Reply-To: <20120706054639.GA32570@shangw>
Message-ID: <alpine.DEB.2.00.1207091417430.23926@chino.kir.corp.google.com>
References: <1341545097-9933-1-git-send-email-shangw@linux.vnet.ibm.com> <CAM_iQpUQN0EEFf5G3RMiR5_51-Pfm2n1kqtQhRuTjQz-wvsmjw@mail.gmail.com> <20120706054639.GA32570@shangw>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org

On Fri, 6 Jul 2012, Gavin Shan wrote:

> >> The initial idea comes from Cong Wang. We're running out of memory
> >> while calling function skip_free_areas_node(). So it would be unsafe
> >> to allocate more memory from either stack or heap. The patche adds
> >> more comments to address that.
> >
> >I think these comments should add to show_free_areas(),
> >not skip_free_areas_node().
> >
> 
> aha, exactly. Thanks a lot, Cong.
> 

There are two issues you're trying to describe here that I told you about:

 - allocating memory on the stack when called in a potentially very deep 
   call chain, and

 - dynamically allocating memory in oom conditions.

There are thousands of functions that could be called potentially very 
deep in a call chain, there's nothing special about this one besides the 
fact that you tried to optimize it by allocating a nodemask on the stack 
in a previous patch.

show_mem(), which calls show_free_areas(), is also not called only in oom 
conditions so the comment wouldn't apply at all.

In other words, there's nothing special about this particular function 
with regard to these traits.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
