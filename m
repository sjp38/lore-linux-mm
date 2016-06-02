From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [BUG/REGRESSION] THP: broken page count after commit aa88b68c
Date: Thu, 2 Jun 2016 21:10:56 +0200
Message-ID: <201606021912.u52JBNvu018445@mx0a-001b2d01.pphosted.com>
References: <20160602172141.75c006a9@thinkpad>
 <20160602155149.GB8493@node.shutemov.name>
 <20160602114031.64b178c823901c171ec82745@linux-foundation.org>
 <201606021856.u52ImC6o037023@mx0a-001b2d01.pphosted.com>
 <20160602120335.4b38dd2bee7b3740ab025f79@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160602120335.4b38dd2bee7b3740ab025f79@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
List-Id: linux-mm.kvack.org

On 06/02/2016 09:03 PM, Andrew Morton wrote:
> On Thu, 2 Jun 2016 20:56:27 +0200 Christian Borntraeger <borntraeger@de.ibm.com> wrote:
> 
>>>> The fix looks good to me.
>>>
>>> Yes.  A bit regrettable, but that's what release_pages() does.
>>>
>>> Can we have a signed-off-by please?
>>
>> Please also add CC: stable for 4.6
> 
> I shall take that as a "yes" and I'll add
> 
> Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
> 
> to the changelog.

Gerald has created the patch,
but you could add 
Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>
