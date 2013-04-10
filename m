Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 7F01E6B003C
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 12:11:54 -0400 (EDT)
Date: Wed, 10 Apr 2013 13:11:46 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: How much memory kernel uses
Message-ID: <20130410161144.GA25394@optiplex.redhat.com>
References: <CABA9-+oTDAOTFYbxeqkXGv1YN4eC-uj86hCihPbS8w-xpJCAxg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CABA9-+oTDAOTFYbxeqkXGv1YN4eC-uj86hCihPbS8w-xpJCAxg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ricardo Jose Pfitscher <ricardo.pfitscher@gmail.com>
Cc: linux-mm@kvack.org

On Tue, Apr 09, 2013 at 10:07:37PM -0300, Ricardo Jose Pfitscher wrote:
>    Hello guys,
>    I need help with memory management, i have a question: Is there a way
>    to find out how much memory is being used by the kernel (preferably
>    form userspace)?
>    Anything like /proc/meminfo....
>    Thank you,
>    --
>    Ricardo Jose Pfitscher

Take a glance at http://www.halobates.de/memorywaste.pdf as a start-point to
understand where the kernel is potentially using memory (the doc is old, and
things might have changed a bit since its publication, but it stills valid as a
study reference). Also, this userland tool might come handy to your studies:
http://www.selenic.com/smem/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
