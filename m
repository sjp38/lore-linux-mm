Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 44F486B005D
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 20:11:03 -0400 (EDT)
Date: Tue, 2 Oct 2012 17:11:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 00/10] Introduce huge zero page
Message-Id: <20121002171101.636cc1b0.akpm@linux-foundation.org>
In-Reply-To: <20121003000402.GA31141@shutemov.name>
References: <1349191172-28855-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20121002153148.1ae1020a.akpm@linux-foundation.org>
	<20121003000402.GA31141@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org

On Wed, 3 Oct 2012 03:04:02 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> Is the overview complete enough? Have I answered all you questions here?

Yes, thanks!

The design overview is short enough to be put in as code comments in
suitable places.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
