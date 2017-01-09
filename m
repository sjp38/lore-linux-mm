Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id E3A826B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 12:58:59 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 67so70596659ioh.1
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 09:58:59 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 19si6457715iof.183.2017.01.09.09.58.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 09:58:59 -0800 (PST)
Date: Mon, 9 Jan 2017 12:58:56 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v15 01/16] mm/free_hot_cold_page: catch ZONE_DEVICE pages
Message-ID: <20170109175856.GB3058@redhat.com>
References: <1483721203-1678-1-git-send-email-jglisse@redhat.com>
 <1483721203-1678-2-git-send-email-jglisse@redhat.com>
 <20170109091952.GA9655@localhost.localdomain>
 <591ef5e3-54a9-da61-bca6-f30641bebe88@intel.com>
 <20170109165712.GA3058@redhat.com>
 <de3ede24-c883-aa6c-c7de-e76f1d0931bc@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <de3ede24-c883-aa6c-c7de-e76f1d0931bc@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Balbir Singh <bsingharora@gmail.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, Jan 09, 2017 at 09:00:34AM -0800, Dave Hansen wrote:
> On 01/09/2017 08:57 AM, Jerome Glisse wrote:
> > On Mon, Jan 09, 2017 at 08:21:25AM -0800, Dave Hansen wrote:
> >> On 01/09/2017 01:19 AM, Balbir Singh wrote:
> >>>> +	/*
> >>>> +	 * This should never happen ! Page from ZONE_DEVICE always must have an
> >>>> +	 * active refcount. Complain about it and try to restore the refcount.
> >>>> +	 */
> >>>> +	if (is_zone_device_page(page)) {
> >>>> +		VM_BUG_ON_PAGE(is_zone_device_page(page), page);
> >>> This can be VM_BUG_ON_PAGE(1, page), hopefully the compiler does the right thing
> >>> here. I suspect this should be a BUG_ON, independent of CONFIG_DEBUG_VM
> >> BUG_ON() means "kill the machine dead".  Do we really want a guaranteed
> >> dead machine if someone screws up their refcounting?
> > VM_BUG_ON_PAGE ok with you ? It is just a safety net, i can simply drop that
> > patch if people have too much feeling about it.
> 
> Enough distros turn on DEBUG_VM that there's basically no difference
> between VM_BUG_ON() and BUG_ON().
> 
> I also think it would be much nicer if you buried the check in the
> allocator in a slow path somewhere instead of sticking it in one of the
> hottest paths in the whole kernel.

Well i will just drop that patch then. The point was to catch error
early on before anything happen. This is just a safety net so not
fundamental.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
