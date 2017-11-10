From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: POWER: Unexpected fault when writing to brk-allocated memory
Date: Fri, 10 Nov 2017 12:08:35 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00B84EF@AcuExch.aculab.com>
References: <d52581f4-8ca4-5421-0862-3098031e29a8@linux.vnet.ibm.com>
 <546d4155-5b7c-6dba-b642-29c103e336bc@redhat.com>
 <20171107160705.059e0c2b@roar.ozlabs.ibm.com>
 <20171107111543.ep57evfxxbwwlhdh@node.shutemov.name>
 <20171107222228.0c8a50ff@roar.ozlabs.ibm.com>
 <20171107122825.posamr2dmzlzvs2p@node.shutemov.name>
 <20171108002448.6799462e@roar.ozlabs.ibm.com>
 <2ce0a91c-985c-aad8-abfa-e91bc088bb3e@linux.vnet.ibm.com>
 <20171107140158.iz4b2lchhrt6eobe@node.shutemov.name>
 <20171110041526.6137bc9a@roar.ozlabs.ibm.com>
 <20171109194421.GA12789@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20171109194421.GA12789@bombadil.infradead.org>
Content-Language: en-US
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
To: 'Matthew Wilcox' <willy@infradead.org>, Nicholas Piggin <npiggin@gmail.com>
Cc: Florian Weimer <fweimer@redhat.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <peterz@infradead.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
List-Id: linux-mm.kvack.org

From: Matthew Wilcox
> Sent: 09 November 2017 19:44
>=20
> On Fri, Nov 10, 2017 at 04:15:26AM +1100, Nicholas Piggin wrote:
> > So these semantics are what we're going with? Anything that does mmap()=
 is
> > guaranteed of getting a 47-bit pointer and it can use the top 17 bits f=
or
> > itself? Is intended to be cross-platform or just x86 and power specific=
?
>=20
> It is x86 and powerpc specific.  The arm64 people have apparently stumble=
d
> across apps that expect to be able to use bit 48 for their own purposes.
> And their address space is 48 bit by default.  Oops.

(Do you mean 49bit?)

Aren't such apps just doomed to be broken?

ISTR there is something on (IIRC) sparc64 that does a 'match'
on the high address bits to make it much harder to overrun
one area into another.

	David
