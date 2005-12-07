Date: Wed, 7 Dec 2005 10:47:45 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: RE: [RFC 1/3] Framework for accurate node based statistics 
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F052359F9@scsmsx401.amr.corp.intel.com>
Message-ID: <Pine.LNX.4.62.0512071046380.24659@schroedinger.engr.sgi.com>
References: <B8E391BBE9FE384DAA4C5C003888BE6F052359F9@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Keith Owens <kaos@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Dec 2005, Luck, Tony wrote:

> Can you live with a pointer to that monster block of space in the
> per-cpu area?
> 
> Otherwise the next step up is a 256K per cpu area ... which I wouldn't
> want to make the default (so we'll have another 2*X explosion in the
> number of possible configs to test).

Lets wait. I just did this to show how local_t could be implemented. This 
is a RFC and the major problems (f.e. the 3 second delay) 
have not been addressed so this is all vaporware for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
