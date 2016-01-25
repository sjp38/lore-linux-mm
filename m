From: Borislav Petkov <bp@alien8.de>
Subject: Re: khugepaged+0x5a6/0x1800 - BUG: unable to handle kernel NULL
 pointer dereference at   (null)
Date: Mon, 25 Jan 2016 12:00:04 +0100
Message-ID: <20160125110004.GA14030@pd.tnic>
References: <20160122181450.GI9806@pd.tnic>
 <20160125104749.GA11541@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160125104749.GA11541@node.shutemov.name>
Sender: linux-kernel-owner@vger.kernel.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Mon, Jan 25, 2016 at 12:47:49PM +0200, Kirill A. Shutemov wrote:
> I think 16fd0fe4aa92 ("mm: fix kernel crash in khugepaged thread") would
> fix this.

Looks similar. Let me run -rc1 on that machine.

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
