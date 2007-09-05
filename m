Message-ID: <46DF14B2.9050402@qumranet.com>
Date: Wed, 05 Sep 2007 23:42:26 +0300
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC]: pte notifiers -- support for external page tables
References: <11890103283456-git-send-email-avi@qumranet.com> <20070905204012.GA29272@sgi.com>
In-Reply-To: <20070905204012.GA29272@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, shaohua.li@intel.com, kvm-devel <kvm-devel@lists.sourceforge.net>, general@lists.openfabrics.org
List-ID: <linux-mm.kvack.org>

[resend due to broken cc list in my original post]

Jack Steiner wrote:
> On Wed, Sep 05, 2007 at 07:38:48PM +0300, Avi Kivity wrote:
>   
>> Some hardware and software systems maintain page tables outside the normal
>> Linux page tables, which reference userspace memory.  This includes
>> Infiniband, other RDMA-capable devices, and kvm (with a pending patch).
>>
>>     
>
> I like it. 
>
> We have 2 special devices with external TLBs that can
> take advantage of this.
>
> One suggestion - at least for what we need. Can the notifier be
> registered against the mm_struct instead of (or in addition to) the
> vma?
>   

Yes.  It's a lot simpler since this way we don't have to support vma
creation/splitting/merging/destruction.  There's a tiny performance hit
for kvm, but it isn't worth the bother.

Will implement for v2 of this patch.

-- 
Any sufficiently difficult bug is indistinguishable from a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
