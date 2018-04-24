Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC326B002D
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:33:53 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id c10-v6so2426135iob.11
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 05:33:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o185-v6sor5142244ita.138.2018.04.24.05.33.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Apr 2018 05:33:52 -0700 (PDT)
Subject: Re: [PATCH 7/9] Pmalloc Rare Write: modify selected pools
References: <20180423125458.5338-1-igor.stoppa@huawei.com>
 <20180423125458.5338-8-igor.stoppa@huawei.com>
 <20180424115050.GD26636@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <98799559-121f-3d9d-343f-b22d30f21b6d@gmail.com>
Date: Tue, 24 Apr 2018 16:33:50 +0400
MIME-Version: 1.0
In-Reply-To: <20180424115050.GD26636@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: keescook@chromium.org, paul@paul-moore.com, sds@tycho.nsa.gov, mhocko@kernel.org, corbet@lwn.net, labbott@redhat.com, david@fromorbit.com, rppt@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>, Carlos Chinea Perez <carlos.chinea.perez@huawei.com>, Remi Denis Courmont <remi.denis.courmont@huawei.com>, linux-security-module@vger.kernel.org



On 24/04/18 15:50, Matthew Wilcox wrote:
> On Mon, Apr 23, 2018 at 04:54:56PM +0400, Igor Stoppa wrote:
>> While the vanilla version of pmalloc provides support for permanently
>> transitioning between writable and read-only of a memory pool, this
>> patch seeks to support a separate class of data, which would still
>> benefit from write protection, most of the time, but it still needs to
>> be modifiable. Maybe very seldom, but still cannot be permanently marked
>> as read-only.
> 
> This seems like a horrible idea that basically makes this feature useless.
> I would say the right way to do this is to have:
> 
> struct modifiable_data {
> 	struct immutable_data *d;
> 	...
> };
> 
> Then allocate a new pool, change d and destroy the old pool.

I'm not sure I understand.

The pool, in the patchset, is a collection of related vm_areas.
What I would like to do is to modify some of the memory that has already 
been handed out as reference, in a way that the reference is not 
altered, nor it requires extensive rewites of  all, in place of he usual 
assignment.

Are you saying that my idea is fundamentally broken?
If yes, how to break it? :-)

If not, I need more coffee, pherhaps we can have a cup together later? :-)

--
igor
