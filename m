Date: Tue, 16 May 2006 16:09:07 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH 0/2][RFC] New version of shared page tables
Message-ID: <2F9DB20EAB953ECFD816E9BF@[10.1.1.4]>
In-Reply-To: <200605081432.40287.raybry@mpdtxmail.amd.com>
References: <1146671004.24422.20.camel@wildcat.int.mccr.org>
 <57DF992082E5BD7D36C9D441@[10.1.1.4]>
 <Pine.LNX.4.64.0605061620560.5462@blonde.wat.veritas.com>
 <200605081432.40287.raybry@mpdtxmail.amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@mpdtxmail.amd.com>, Hugh Dickins <hugh@veritas.com>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--On Monday, May 08, 2006 14:32:39 -0500 Ray Bryant
<raybry@mpdtxmail.amd.com> wrote:
> On Saturday 06 May 2006 10:25, Hugh Dickins wrote:
> <snip>
>> How was Ray Bryant's shared,anonymous,fork,munmap,private bug of
>> 25 Jan resolved?  We didn't hear the end of that.
>> 
> 
> I never heard anything back from Dave, either.

My apologies.  As I recall your problem looked to be a race in an area
where I was redoing the concurrency control.  I intended to ask you to
retest when my new version came out.  Unfortunately the new version took
awhile, and by the time I sent it out I forgot to ask you about it.

I believe your problem should be fixed in recent versions.  If not, I'll
make another pass at it.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
