Message-ID: <3D5B253A.31998AEF@zip.com.au>
Date: Wed, 14 Aug 2002 20:51:22 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: dynamic linked libraries
References: <Pine.SOL.4.33.0208142303010.18485-100000@violet.engin.umich.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hai Huang <haih@engin.umich.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hai Huang wrote:
> 
> Is there anyway to spot whether a vm_area_struct is used to map a dynamic
> linked library somehow?
> 

Don't think so.  If it has a vm_file, and the protection bits
are right then there's a good chance.

If it's just for debug/devel code and doesn't have to be 100% accurate
then you could perhaps also go fishing inside vm_file->f_dentry->d_name
for the substring ".so".
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
