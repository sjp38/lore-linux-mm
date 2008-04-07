From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [ofa-general] Re: [patch 01/10] emm: mm_lock: Lock a process against
	reclaim
Date: Mon, 07 Apr 2008 15:55:48 +0200
Message-ID: <1207576548.15579.43.camel@twins>
References: <20080404223048.374852899@sgi.com>
	<20080404223131.271668133@sgi.com> <47F6B5EA.6060106@goop.org>
	<20080405004127.GG14784@duo.random>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080405004127.GG14784@duo.random>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, kvm-devel@lists.sourceforge.net, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Christoph Lameter <clameter@sgi.com>
List-Id: linux-mm.kvack.org

On Sat, 2008-04-05 at 02:41 +0200, Andrea Arcangeli wrote:
> On Fri, Apr 04, 2008 at 04:12:42PM -0700, Jeremy Fitzhardinge wrote:
> > I think you can break this if() down a bit:
> >
> > 			if (!(vma->vm_file && vma->vm_file->f_mapping))
> > 				continue;
> 
> It makes no difference at runtime, coding style preferences are quite
> subjective.

I'll have to concurr with Jeremy here, please break that monstrous if
stmt down. It might not matter to the compiler, but it sure as hell
helps for anyone trying to understand/maintain the thing.
