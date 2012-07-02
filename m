Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id C5EEA6B0068
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 06:59:43 -0400 (EDT)
Message-ID: <4FF17E7D.5020302@parallels.com>
Date: Mon, 2 Jul 2012 14:57:01 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] make CFLGS_OFF_SLAB visible for all slabs
References: <1339676244-27967-1-git-send-email-glommer@parallels.com> <1339676244-27967-5-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206141019010.32075@router.home>
In-Reply-To: <alpine.DEB.2.00.1206141019010.32075@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, cgroups@vger.kernel.org, devel@openvz.org, Pekka
 Enberg <penberg@cs.helsinki.fi>

On 06/14/2012 07:19 PM, Christoph Lameter wrote:
> On Thu, 14 Jun 2012, Glauber Costa wrote:
> 
>> Since we're now moving towards a unified slab allocator interface,
>> make CFLGS_OFF_SLAB visible to all allocators, even though SLAB keeps
>> being its only users. Also, make the name consistent with the other
>> flags, that start with SLAB_xx.
> 
> What is the significance of knowledge about internal slab structures (such
> as the CFGLFS_OFF_SLAB) outside of the allocators?
> 
Pekka, please note this comment when you are scanning through the series
(which you seem to be doing now).

This one is better left off for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
