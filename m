Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: Correctly determine free memory amount before swapping
Date: Wed, 8 Dec 2004 16:17:09 +0200
Message-ID: <06EF4EE36118C94BB3331391E2CDAAD9D49E06@exil1.paradigmgeo.net>
From: "Gregory Giguashvili" <Gregoryg@ParadigmGeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I apologize if this question was already discussed here - Google search
revealed lots of similar topics, but none in this particular aspect.

I need to commit the largest chunk of memory in the quickest way. This
operation may be slowed down by swapping - that's why I don't want to
get there.

Assuming that I define "free memory" as maximum memory that can be
allocated without causing swapping, is there a way I can give a rough
"free memory" amount estimate? I've tried to play with /proc/meminfo
values with some progress, but I'd like to get a qualified answer from
people working with MM.

According to my humble experiments with 2.4 and 2.6 kernels, some cashed
memory reported in /proc/meminfo is reused and some is swapped. The real
problem here is that I not sure what the right way is to "predict" how
much cached memory will be discarded before starting to swap when system
is low on available RAM.

In 2.4 kernels, I was using the following formula (/proc/meminfo names):
free = MemFree + (Inact_dirty > Inact_target ? Inact_dirty -
Inact_target : 0)

In 2.6 kernels, I'm still working on it.

I understand that this is a complicated question, but I'm looking for a
rough simplification of this matter that would work in most of the cases
with little or no swapping.

Any suggestions are greatly appreciated. 

Thanks a lot
Giga
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
