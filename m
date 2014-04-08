From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/5] hugetlb: update_and_free_page(): don't clear
 PG_reserved bit
Date: Tue, 8 Apr 2014 23:51:26 +0300
Message-ID: <20140408205126.GA2778@node.dhcp.inet.fi>
References: <1396983740-26047-1-git-send-email-lcapitulino@redhat.com>
 <1396983740-26047-4-git-send-email-lcapitulino@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1396983740-26047-4-git-send-email-lcapitulino@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com, n-horiguchi@ah.jp.nec.com
List-Id: linux-mm.kvack.org

On Tue, Apr 08, 2014 at 03:02:18PM -0400, Luiz Capitulino wrote:
> Hugepages pages never get the PG_reserved bit set, so don't clear it. But
> add a warning just in case.

I don't think WARN_ON() is needed. PG_reserved will be catched by
free_pages_check().

-- 
 Kirill A. Shutemov
