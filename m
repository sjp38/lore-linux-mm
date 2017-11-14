Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1E96B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 05:02:04 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n8so3733779wmg.4
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 02:02:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9si4836521edm.95.2017.11.14.02.02.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Nov 2017 02:02:03 -0800 (PST)
Date: Tue, 14 Nov 2017 11:02:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: replace FSF address with web source in license
 notices
Message-ID: <20171114100202.bbegvtz6jckuyzcm@dhcp22.suse.cz>
References: <20171114094438.28224-1-martink@posteo.de>
 <20171114094946.owfohzm5iplttdw6@dhcp22.suse.cz>
 <21c380cbf6a51b6823a1707b0d16b25e@posteo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <21c380cbf6a51b6823a1707b0d16b25e@posteo.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Kepplinger <martink@posteo.de>
Cc: catalin.marinas@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 14-11-17 10:55:35, Martin Kepplinger wrote:
> Am 14.11.2017 10:49 schrieb Michal Hocko:
> > On Tue 14-11-17 10:44:38, Martin Kepplinger wrote:
> > > A few years ago the FSF moved and "59 Temple Place" is wrong. Having
> > > this
> > > still in our source files feels old and unmaintained.
> > > 
> > > Let's take the license statement serious and not confuse users.
> > > 
> > > As https://www.gnu.org/licenses/gpl-howto.html suggests, we replace
> > > the
> > > postal address with "<http://www.gnu.org/licenses/>" in the mm
> > > directory.
> > 
> > Why to change this now? Isn't there a general plan to move to SPDX?
> 
> Shouldn't a move to SPDX only be additions to what we currently have? That's
> at least what the "reuse" project suggests, see
> https://reuse.software/practices/
> with "Dona??t remove existing headers, but only add to them."

I thought the primary motivation was to unify _all_ headers and get rid
of all the duplication. (aside from files which do not have any license
which is under discussion elsewhere).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
