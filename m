Date: Wed, 18 Aug 1999 20:59:52 +0900
From: Neil Booth <NeilB@earthling.net>
Subject: Re: where does vmlist be initiated?
Message-ID: <19990818205952.B8819@monkey.rosenet.ne.jp>
References: <000901bee855$ec448410$0601a8c0@honey.cs.tsinghua.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
In-Reply-To: <000901bee855$ec448410$0601a8c0@honey.cs.tsinghua.edu.cn>; from Wang Yong on Tue, Aug 17, 1999 at 10:12:10AM +0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Wang Yong <wung_y@263.net>
Cc: Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Wang Yong wrote:-
> hi,
>   i found this structure is defined in mm/vmalloc.c :
>   "static struct vm_struct * vmlist = NULL;"
> 
>   it appears that vmlist be initiated as null. but in function
> get_vm_area(), which is called by kmalloc(), it doesn't work if vmlist is
> null. so i think vmlist must be initiated somewhere else. but where? thx

Hi Wang,

There's only 3 lines that reference it in vmalloc.c, so it
shouldn't be too hard to figure out, no?

Neil.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
