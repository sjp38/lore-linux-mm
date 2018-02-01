Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id D8C126B000A
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 08:22:30 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id h8so12177031ote.8
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 05:22:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t21si900897oie.402.2018.02.01.05.22.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 05:22:30 -0800 (PST)
Date: Thu, 1 Feb 2018 08:22:26 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM TOPIC] Killing reliance on struct page->mapping
Message-ID: <20180201132225.GA2864@redhat.com>
References: <20180130004347.GD4526@redhat.com>
 <20180131165646.GI29051@ZenIV.linux.org.uk>
 <20180131174245.GE2912@redhat.com>
 <20180201122752.xrlzy4lmjkvauge4@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180201122752.xrlzy4lmjkvauge4@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Thu, Feb 01, 2018 at 03:27:52PM +0300, Kirill A. Shutemov wrote:
> On Wed, Jan 31, 2018 at 12:42:45PM -0500, Jerome Glisse wrote:
> > The overall idea i have is that in any place in the kernel (except memory reclaim
> > but that's ok) we can either get mapping or buffer_head information without relying
> > on struct page and if we have either one and a struct page then we can find the
> > other one.
> 
> Why is it okay for reclaim?
> 
> And what about physical memory scanners that doesn't have any side information
> about the page they step onto?

Reclaim is only interested in unmapping and reclaiming, KSM already provide
special function for unmapping (rmap walk) so it is just about extending that
for file back page.

For physical memory scanners it depends on what their individual objectives are.
I have not reviewed them but had the feeling that i could add special KSM helpers
to achieve aims of each one of them.

The mapping information is not lost, it would just not be easily accessible
for those write protected pages.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
