Date: Tue, 11 Dec 2001 13:13:42 -0500
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: Allocation of kernel memory >128K
Message-ID: <20011211131342.D6400@redhat.com>
References: <OF1B7C1C46.B55EBB52-ON86256B1F.00536DEC@hou.us.ray.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF1B7C1C46.B55EBB52-ON86256B1F.00536DEC@hou.us.ray.com>; from Mark_H_Johnson@Raytheon.com on Tue, Dec 11, 2001 at 09:27:36AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson@Raytheon.com
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, "Amit S. Jain" <amitjain@tifr.res.in>, linux-mm@kvack.org, owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Dec 11, 2001 at 09:27:36AM -0600, Mark_H_Johnson@Raytheon.com wrote:
> I would not necessarily say that "large amounts of continuous memory is a
> bad thing" - rather that it is hard to get, and a costly operation (in
> time). For example - a number of existing pages must be moved (or swapped)
> to get the area you are requesting. Since this is a big performance hit,
> you better have a really good reason for doing so.

Don't even bother thinking about performance: it is unreliable.

		-ben
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
