Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 1CF996B0005
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 09:14:45 -0500 (EST)
Date: Thu, 24 Jan 2013 22:14:41 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] Negative (setpoint-dirty) in bdi_position_ratio()
Message-ID: <20130124141441.GA12745@localhost>
References: <201301200002.r0K02Atl031280@como.maths.usyd.edu.au>
 <20130122235438.GB7497@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130122235438.GB7497@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: paul.szabo@sydney.edu.au, linux-mm@kvack.org, 695182@bugs.debian.org, linux-kernel@vger.kernel.org

On Wed, Jan 23, 2013 at 12:54:38AM +0100, Jan Kara wrote:
> On Sun 20-01-13 11:02:10, paul.szabo@sydney.edu.au wrote:
> > In bdi_position_ratio(), get difference (setpoint-dirty) right even when
> > negative. Both setpoint and dirty are unsigned long, the difference was
> > zero-padded thus wrongly sign-extended to s64. This issue affects all
> > 32-bit architectures, does not affect 64-bit architectures where long
> > and s64 are equivalent.
> > 
> > In this function, dirty is between freerun and limit, the pseudo-float x
> > is between [-1,1], expected to be negative about half the time. With
> > zero-padding, instead of a small negative x we obtained a large positive
> > one so bdi_position_ratio() returned garbage.
> > 
> > Casting the difference to s64 also prevents overflow with left-shift;
> > though normally these numbers are small and I never observed a 32-bit
> > overflow there.
> > 
> > (This patch does not solve the PAE OOM issue.)
> > 
> > Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
> > School of Mathematics and Statistics   University of Sydney    Australia
> > 
> > Reported-by: Paul Szabo <psz@maths.usyd.edu.au>
> > Reference: http://bugs.debian.org/695182
> > Signed-off-by: Paul Szabo <psz@maths.usyd.edu.au>
>   Ah, good catch. Thanks for the patch. You can add:
> Reviewed-by: Jan Kara <jack@suse.cz>
> 
>   I've also added CC to writeback maintainer.

Applied. Thanks! It's a good fix.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
