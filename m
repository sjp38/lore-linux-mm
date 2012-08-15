Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id DA35D6B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 07:40:47 -0400 (EDT)
Received: by qady1 with SMTP id y1so1368582qad.14
        for <linux-mm@kvack.org>; Wed, 15 Aug 2012 04:40:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50201BB5.9050005@jp.fujitsu.com>
References: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com>
	<CA+5PVA4CE0kwD1FmV=081wfCObVYe5GFYBQFO9_kVL4JWJBqpA@mail.gmail.com>
	<50201BB5.9050005@jp.fujitsu.com>
Date: Wed, 15 Aug 2012 07:40:46 -0400
Message-ID: <CA+5PVA7YejzbWDEpX=gj8s2QAQtgoxyNUUa5HhGtVGY+2BHqRA@mail.gmail.com>
Subject: Re: [PATCH 0/6][resend] mempolicy memory corruption fixlet
From: Josh Boyer <jwboyer@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: kosaki.motohiro@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@google.com, davej@redhat.com, mgorman@suse.de, cl@linux.com, stable@vger.kernel.org

On Mon, Aug 6, 2012 at 3:32 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> On 7/31/2012 8:33 AM, Josh Boyer wrote:
>> On Mon, Jun 11, 2012 at 5:17 AM,  <kosaki.motohiro@gmail.com> wrote:
>>> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>>
>>> Hi
>>>
>>> This is trivial fixes of mempolicy meory corruption issues. There
>>> are independent patches each ather. and, they don't change userland
>>> ABIs.
>>>
>>> Thanks.
>>>
>>> changes from v1: fix some typo of changelogs s.
>>>
>>> -----------------------------------------------
>>> KOSAKI Motohiro (6):
>>>   Revert "mm: mempolicy: Let vma_merge and vma_split handle
>>>     vma->vm_policy linkages"
>>>   mempolicy: Kill all mempolicy sharing
>>>   mempolicy: fix a race in shared_policy_replace()
>>>   mempolicy: fix refcount leak in mpol_set_shared_policy()
>>>   mempolicy: fix a memory corruption by refcount imbalance in
>>>     alloc_pages_vma()
>>>   MAINTAINERS: Added MEMPOLICY entry
>>>
>>>  MAINTAINERS    |    7 +++
>>>  mm/mempolicy.c |  151 ++++++++++++++++++++++++++++++++++++++++----------------
>>>  mm/shmem.c     |    9 ++--
>>>  3 files changed, 120 insertions(+), 47 deletions(-)
>>
>> I don't see these patches queued anywhere.  They aren't in linux-next,
>> mmotm, or Linus' tree.  Did these get dropped?  Is the revert still
>> needed?
>
> Sorry. my fault. yes, it is needed. currently, Some LTP was fail since
> Mel's "mm: mempolicy: Let vma_merge and vma_split handle vma->vm_policy linkages" patch.

The series still isn't queued anywhere.  Are you planning on resending
it again, or should it get picked up in a particular tree?

josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
