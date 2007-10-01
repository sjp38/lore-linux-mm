Date: Tue, 2 Oct 2007 01:14:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Hotplug memory remove
Message-Id: <20071002011447.7ec1f513.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1191253063.29581.7.camel@dyn9047017100.beaverton.ibm.com>
References: <1191253063.29581.7.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 01 Oct 2007 08:37:43 -0700
Badari Pulavarty <pbadari@gmail.com> wrote:
> 1) Other than remove_memory(), I don't see any other arch-specific
> code that needs to be provided. Even remove_memory() looks pretty
> arch independent. Isn't it ?
> 
Yes, maybe arch independent. Current codes is based on assumption
that some arch may needs some code before/after hotremove.
If no arch needs, we can merge all. 

> 2) I copied remove_memory() from IA64 to PPC64. When I am testing
> hotplug-remove (echo offline > state), I am not able to remove
> any memory at all. I get different type of failures like ..
> 
> memory offlining 6e000 to 6f000 failed
> 
I'm not sure about this...does this memory is in ZONE_MOVABLE ?
If not ZONE_MOVABLE, offlining can be fail because of not-removable
kernel memory. 

> - OR -
> 
> Offlined Pages 0
> 
Hmm, About "Offlined Pages 0" case, maybe memory resource is not
registered. At memory hotremove works based on registered memory resource.
(For handling memory hole.)

Does PPC64 resister conventinal memory to memory resource ?
This information can be shown in /proc/iomem.
In current code, removable memory must be registerred in /proc/iomem.
Could you confirm ?

> I am wondering, how did you test it on IA64 ? Am I missing something ?
> How can I find which "sections" of the memory are free to remove ?
> I am using /proc/page_owner to figure it out for now.
> 
create ZONE_MOVBALE with kernelcore= boot option and offlined memory in it.
ia64 registers all available memory information to /proc/iomem.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
