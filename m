Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B49386B0007
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 12:35:36 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 66so8341926pgh.2
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 09:35:36 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id a1-v6si4355477plt.588.2018.01.30.09.35.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Jan 2018 09:35:35 -0800 (PST)
Message-ID: <1517333732.3118.49.camel@HansenPartnership.com>
Subject: Re: [LSF/MM TOPIC] mm documentation
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 30 Jan 2018 09:35:32 -0800
In-Reply-To: <20180130142849.GD21333@rapoport-lnx>
References: <20180130105237.GB7201@rapoport-lnx>
	 <20180130105450.GC7201@rapoport-lnx>
	 <20180130115055.GZ21609@dhcp22.suse.cz>
	 <20180130125443.GA21333@rapoport-lnx>
	 <20180130134141.GD21609@dhcp22.suse.cz>
	 <20180130142849.GD21333@rapoport-lnx>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue, 2018-01-30 at 16:28 +0200, Mike Rapoport wrote:
> On Tue, Jan 30, 2018 at 02:41:41PM +0100, Michal Hocko wrote:
> > 
> > On Tue 30-01-18 14:54:44, Mike Rapoport wrote:
> > > 
> > > On Tue, Jan 30, 2018 at 12:50:55PM +0100, Michal Hocko wrote:
> > > > 
> > > > On Tue 30-01-18 12:54:50, Mike Rapoport wrote:
> > > > > 
> > > > > (forgot to CC linux-mm)
> > > > > 
> > > > > On Tue, Jan 30, 2018 at 12:52:37PM +0200, Mike Rapoport
> > > > > wrote:
> > > > > > 
> > > > > > Hello,
> > > > > > 
> > > > > > The mm kernel-doc documentation is not in a great shape.A 
> > > > > > 
> > > > > > Some of the existing kernel-doc annotations were not
> > > > > > reformatted during transition from dockbook to sphix.
> > > > > > Sometimes the parameter descriptions do not match actual
> > > > > > code. But aside these rather mechanical issues there
> > > > > > are several points it'd like to discuss:
> > > > > > 
> > > > > > * Currently, only 14 files are linked to kernel-api.rst
> > > > > > under "Memory Management in Linux" section. We have more
> > > > > > than hundred files only in mm. Even the existing
> > > > > > documentation is not generated when running "make
> > > > > > htmldocs"
> > > > 
> > > > Is this documentation anywhere close to be actually useful?
> > > 
> > > Some parts are documented better, some worse. For instance,
> > > bootmem and z3fold are covered not bad at all, but, say,
> > > huge_memory has no structured comments at all. Roughly half of
> > > the files in mm/ have some documentation, but I didn't yet read
> > > that all to say how much of it is actually useful.
> > 
> > It is good to hear that at least something has a documentation
> > coverage. I was asking mostly because I _think_ that the API
> > documentation is far from the top priority.A 
> 
> API documentations is important for kernel developers who are not
> deeply involved with mm. When one develops a device driver, knowing
> how to allocate and free memory is essential. And, while *malloc are
> included in kernel-api.rst, CMA and HMM documentation is not visible.

Documentation is also one way new people get into the project.A A Not
being top priority is fine, but "far from" top priority implies not
worth doing, which gives the wrong impression.

> > We are seriously lacking any highlevel one which describes the
> > design and subsytems interaction.
> 
> I should have describe it better, but by "creating a new structure
> for mm documentation" I've also meant adding high level description.
> 
> > 
> > Well, we have missed that train years ago. It will be really hard
> > to catch up.
> 
> At least we can try.

How about simply insisting on adequately documenting new stuff and
asking submitters to add documentation when they change something.A A The
latter, at least, is fairly essential: there's nothing worse than
documentation that's actively wrong. A The former is useful to
reviewers. A I'm not saying this alone will ever get you to 100%, but at
least it's an incremental change which isn't too burdensome and which
moves the needle in the right direction.

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
