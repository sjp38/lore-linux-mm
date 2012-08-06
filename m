Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 68DA36B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 15:31:59 -0400 (EDT)
Message-ID: <50201BB5.9050005@jp.fujitsu.com>
Date: Mon, 06 Aug 2012 15:32:05 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6][resend] mempolicy memory corruption fixlet
References: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com> <CA+5PVA4CE0kwD1FmV=081wfCObVYe5GFYBQFO9_kVL4JWJBqpA@mail.gmail.com>
In-Reply-To: <CA+5PVA4CE0kwD1FmV=081wfCObVYe5GFYBQFO9_kVL4JWJBqpA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jwboyer@gmail.com
Cc: kosaki.motohiro@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@google.com, davej@redhat.com, mgorman@suse.de, cl@linux.com, stable@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com

On 7/31/2012 8:33 AM, Josh Boyer wrote:
> On Mon, Jun 11, 2012 at 5:17 AM,  <kosaki.motohiro@gmail.com> wrote:
>> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>
>> Hi
>>
>> This is trivial fixes of mempolicy meory corruption issues. There
>> are independent patches each ather. and, they don't change userland
>> ABIs.
>>
>> Thanks.
>>
>> changes from v1: fix some typo of changelogs s.
>>
>> -----------------------------------------------
>> KOSAKI Motohiro (6):
>>   Revert "mm: mempolicy: Let vma_merge and vma_split handle
>>     vma->vm_policy linkages"
>>   mempolicy: Kill all mempolicy sharing
>>   mempolicy: fix a race in shared_policy_replace()
>>   mempolicy: fix refcount leak in mpol_set_shared_policy()
>>   mempolicy: fix a memory corruption by refcount imbalance in
>>     alloc_pages_vma()
>>   MAINTAINERS: Added MEMPOLICY entry
>>
>>  MAINTAINERS    |    7 +++
>>  mm/mempolicy.c |  151 ++++++++++++++++++++++++++++++++++++++++----------------
>>  mm/shmem.c     |    9 ++--
>>  3 files changed, 120 insertions(+), 47 deletions(-)
> 
> I don't see these patches queued anywhere.  They aren't in linux-next,
> mmotm, or Linus' tree.  Did these get dropped?  Is the revert still
> needed?

Sorry. my fault. yes, it is needed. currently, Some LTP was fail since
Mel's "mm: mempolicy: Let vma_merge and vma_split handle vma->vm_policy linkages" patch.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
