Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4093D6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:27:17 -0500 (EST)
Date: Tue, 10 Nov 2009 14:26:29 -0700
From: Alex Chiang <achiang@hp.com>
Subject: Re: [patch -mm] mm: slab allocate memory section nodemask for
	large systems
Message-ID: <20091110212629.GD27861@ldl.fc.hp.com>
References: <alpine.DEB.2.00.0910221249030.26631@chino.kir.corp.google.com> <20091027195907.GJ14102@ldl.fc.hp.com> <alpine.DEB.2.00.0910271422090.22335@chino.kir.corp.google.com> <20091028083137.GA24140@osiris.boeblingen.de.ibm.com> <alpine.DEB.2.00.0910280159380.7122@chino.kir.corp.google.com> <20091028183905.GF22743@ldl.fc.hp.com> <alpine.DEB.2.00.0910281315370.23279@chino.kir.corp.google.com> <20091102204726.GG5525@ldl.fc.hp.com> <20091110125131.30376c03.akpm@linux-foundation.org> <alpine.DEB.2.00.0911101255020.28728@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0911101255020.28728@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Gary Hade <garyhade@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Badari Pulavarty <pbadari@us.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

* David Rientjes <rientjes@google.com>:
> On Tue, 10 Nov 2009, Andrew Morton wrote:
> 
> > The prerequisite Documentation/ patches are a bit of a mess - some have
> > been cherrypicked into Greg's tree I believe and some haven't.  So
> > please also send out whatever is needed to bring linux-next up to date.

Thanks, I'll respin.

> I'm not aware of any prerequisites for this patchset, Alex's documentation 
> changes have already been merged by Linus.

Correct. So I'll respin this series against... Linus's tree? Or
maybe mmotm? Please advise.

Thanks,
/ac

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
