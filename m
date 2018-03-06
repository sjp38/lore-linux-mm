Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2EC6B0003
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 09:58:15 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id t12-v6so9951749plo.9
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 06:58:15 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id c1si9933854pgq.109.2018.03.06.06.58.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 06:58:14 -0800 (PST)
Date: Tue, 6 Mar 2018 17:58:06 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [RFC, PATCH 21/22] x86/mm: Introduce page_keyid() and
 page_encrypted()
Message-ID: <20180306145806.ejg5kzaqqmncgqi7@black.fi.intel.com>
References: <20180305162610.37510-1-kirill.shutemov@linux.intel.com>
 <20180305162610.37510-22-kirill.shutemov@linux.intel.com>
 <61041640-435e-1a67-177f-a75791130514@intel.com>
 <20180306085751.tvozsfe6hogh37pd@node.shutemov.name>
 <91d27559-3f28-d53c-9fd9-d16e015a3f59@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <91d27559-3f28-d53c-9fd9-d16e015a3f59@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 06, 2018 at 02:56:08PM +0000, Dave Hansen wrote:
> On 03/06/2018 12:57 AM, Kirill A. Shutemov wrote:
> > On Mon, Mar 05, 2018 at 09:08:53AM -0800, Dave Hansen wrote:
> >> On 03/05/2018 08:26 AM, Kirill A. Shutemov wrote:
> >>> +static inline bool page_encrypted(struct page *page)
> >>> +{
> >>> +	/* All pages with non-zero KeyID are encrypted */
> >>> +	return page_keyid(page) != 0;
> >>> +}
> >>
> >> Is this true?  I thought there was a KEYID_NO_ENCRYPT "Do not encrypt
> >> memory when this KeyID is in use."  Is that really only limited to key 0.
> > 
> > Well, it depends on what we mean by "encrypted". For memory management
> > pruposes we care if the page is encrypted with KeyID different from
> > default one. All pages with non-default KeyID threated the same by memory
> > management.
> 
> Doesn't it really mean "am I able to use the direct map to get this
> page's contents?"

Yes.

Any proposal for better helper name?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
