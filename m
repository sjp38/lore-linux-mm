Message-Id: <200106252339.f5PNd9x07535@maile.telia.com>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Roger Larsson <roger.larsson@norran.net>
Subject: Re: [RFC] VM statistics to gather
Date: Tue, 26 Jun 2001 01:35:42 +0200
References: <Pine.LNX.4.33L.0106252002560.23373-100000@duckman.distro.conectiva>
In-Reply-To: <Pine.LNX.4.33L.0106252002560.23373-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

What about

   unsigned int vm_pgfails /* failed alloc attempts, in pages (not calls) */

maybe even a

   unsigned int vm_pgallocs /* alloc attempts, in pages */

for sanity checking - should be the sum of several other combinations...

Should memory zone be used as dimension?


/RogerL


-- 
Roger Larsson
Skelleftea
Sweden

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
