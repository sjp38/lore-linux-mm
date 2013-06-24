Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id A56C46B007D
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 07:48:33 -0400 (EDT)
Date: Mon, 24 Jun 2013 04:48:32 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: RFC: named anonymous vmas
Message-ID: <20130624114832.GA9961@infradead.org>
References: <CAMbhsRQU=xrcum+ZUbG3S+JfFUJK_qm_VB96Vz=PpL=vQYhUvg@mail.gmail.com>
 <20130622103158.GA16304@infradead.org>
 <CAMbhsRTz246dWPQOburNor2HvrgbN-AWb2jT_AEywtJHFbKWsA@mail.gmail.com>
 <kq4v0b$p8p$3@ger.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <kq4v0b$p8p$3@ger.gmane.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Elsayed <eternaleye@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Jun 22, 2013 at 12:47:29PM -0700, Alex Elsayed wrote:
> Couldn't this be done by having a root-only tmpfs, and having a userspace 
> component that creates per-app directories with restrictive permissions on 
> startup/app install? Then each app creates files in its own directory, and 
> can pass the fds around.

Honestly having a device that allows passing fds around that can be
mmaped sounds a lot simpler.  I have to admit that I expect /dev/zero
to do this, but looking at the code it creates new file structures
at ->mmap time which would defeat this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
