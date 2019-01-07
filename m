Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id F11528E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 17:44:13 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id y2so960834plr.8
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 14:44:13 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z19si25157055pfc.95.2019.01.07.14.44.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 14:44:12 -0800 (PST)
Date: Mon, 7 Jan 2019 14:44:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm: Create the new vm_fault_t type
Message-Id: <20190107144411.b3e2313649f106de0776432e@linux-foundation.org>
In-Reply-To: <CAFqt6zYY=xfqvVxRi1spbMNzvoM_CYNxbm6d7_79a5bBHxUzuA@mail.gmail.com>
References: <20181106120544.GA3783@jordon-HP-15-Notebook-PC>
	<20181115014737.GA2353@rapoport-lnx>
	<CAFqt6zbOgSm9omt+6iV0GJtZdZ_qyTr9Jte9ZGYRQ1M4CdB-mA@mail.gmail.com>
	<CAFqt6zZ67tFA8FjFZ4xM+YUAez9EdPHinx0ky0X5sQHyZ9nkLg@mail.gmail.com>
	<CAFqt6zYY=xfqvVxRi1spbMNzvoM_CYNxbm6d7_79a5bBHxUzuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: rppt@linux.ibm.com, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, riel@redhat.com, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Mon, 7 Jan 2019 11:47:12 +0530 Souptick Joarder <jrdr.linux@gmail.com> wrote:

> > Do I need to make any further improvement for this patch ?
> 
> If no further comment, can we get this patch in queue for 5.0-rcX ?

I stopped paying attention a while ago, sorry.

Please resend everything which you believe is ready to go.
