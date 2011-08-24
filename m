Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 725036B0169
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 12:10:14 -0400 (EDT)
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1QwG1p-00006R-He
	for linux-mm@kvack.org; Wed, 24 Aug 2011 18:10:09 +0200
Received: from 112.80.155.140 ([112.80.155.140])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 24 Aug 2011 18:10:09 +0200
Received: from wanlong.gao by 112.80.155.140 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 24 Aug 2011 18:10:09 +0200
From: Wanlong Gao <wanlong.gao@gmail.com>
Subject: Re: [PATCH -v3] avoid null pointer access in =?utf-8?b?dm1fc3RydWN0?=
Date: Wed, 24 Aug 2011 15:58:24 +0000 (UTC)
Message-ID: <loom.20110824T175141-583@post.gmane.org>
References: <20110821082132.28358.72280.stgit@ltc219.sdl.hitachi.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Mitsuo Hayasaka <mitsuo.hayasaka.hu <at> hitachi.com> writes:

> 
> The /proc/vmallocinfo shows information about vmalloc allocations in vmlist
> that is a linklist of vm_struct. It, however, may access pages field of
> vm_struct where a page was not allocated. This results in a null pointer
> access and leads to a kernel panic.

> +static void insert_vmalloc_vmlist(struct vm_struct *vm)
> +{
> +	struct vm_struct *tmp, **p;
> 
> +	vm->flags &= ~VM_UNLIST;
>  	write_lock(&vmlist_lock);
>  	for (p = &vmlist; (tmp = *p) != NULL; p = &tmp->next) {
>  		if (tmp->addr >= vm->addr)
> @@ -1275,6 +1279,13 @@ static void insert_vmalloc_vm(struct vm_struct *vm,
struct vmap_area *va,
>  	write_unlock(&vmlist_lock);
>  }

Hi Mitsuo:
Is it needed to set the VM_UNLIST after vm_struct added to vmlist here?
or put it into lock protection?
Thanks
-Wanlong Gao


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
