From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: pre2 swap_out() changes
Date: Sun, 14 Jan 2001 10:51:29 -0500
Content-Type: text/plain;
  charset="US-ASCII"
References: <Pine.LNX.4.21.0101140136200.11917-100000@freak.distro.conectiva>
In-Reply-To: <Pine.LNX.4.21.0101140136200.11917-100000@freak.distro.conectiva>
MIME-Version: 1.0
Message-Id: <01011410512900.02185@oscar>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

A couple of observations on the pre2/pre3 vm.  It seems to start swapping out 
very quicky but this does not seem to hurt.  Once there is memory preasure 
and swapin starts cpu utilization drops thru the roof - kernel compiles are 
only able to drive the system at 10-20% (UP instead of 95-100%).  Once the 
system stops swapping (in) there are some side effects.  Closing windows 
in X becomes jerky (ie you see blocks get cleared and refreshed).  If little 
or no swapping has occured X is much faster.

With the patch marcelo posted last night things change.  Now It can use cpu 
when swapping.  It does seem to start swaping (in and out) faster but the 
system remains more interactive than above.  I still see the X effect though.

Over all I think 2.4.0+marcelo's first patch(es) was fastest.

Ed Tomlinson
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
