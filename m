Date: Thu, 12 Jun 2003 16:07:40 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] Fix vmtruncate race and distributed filesystem race
Message-Id: <20030612160740.27a57aca.akpm@digeo.com>
In-Reply-To: <184910000.1055458610@baldur.austin.ibm.com>
References: <133430000.1055448961@baldur.austin.ibm.com>
	<20030612134946.450e0f77.akpm@digeo.com>
	<20030612140014.32b7244d.akpm@digeo.com>
	<150040000.1055452098@baldur.austin.ibm.com>
	<20030612144418.49f75066.akpm@digeo.com>
	<184910000.1055458610@baldur.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave McCracken <dmccr@us.ibm.com> wrote:
>
> I also think if we can solve both the vmtruncate and the distributed file
> system races without adding any vm_ops, we should.
> 
> Here's a new patch.  Does this look better?

grumble, mutter.  It's certainly simple enough.

+	mapping = vma->vm_file->f_dentry->d_inode->i_mapping;

I'm not so sure about this one now.  write() alters dentry->d_inode but
truncate alters dentry->d_inode->i_mapping->host.  Unless truncate is
changed we have the wrong mapping here.

I'll put it back to the original while I try to work out why truncate isn't
wrong...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
